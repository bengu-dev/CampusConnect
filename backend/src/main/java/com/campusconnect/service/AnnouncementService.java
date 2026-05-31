package com.campusconnect.service;

import com.campusconnect.dto.AnnouncementDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class AnnouncementService {

    private final JdbcTemplate          jdbc;
    private final SimpMessagingTemplate messaging;

    // ── Duyuru listesi — role göre filtreli, en yeni önce ─────────────────

    public List<AnnouncementDto> getAnnouncements(String userRole) {
        return jdbc.query(
            """
            SELECT a.id, a.title, a.content, a.target_role, a.created_at,
                   u.first_name || ' ' || u.last_name AS author_name
            FROM announcements a
            LEFT JOIN users u ON u.id = a.author_id
            WHERE a.is_active = TRUE
              AND (a.expires_at IS NULL OR a.expires_at > NOW())
              AND (a.target_role = 'ALL' OR a.target_role = ?)
            ORDER BY a.created_at DESC
            LIMIT 50
            """,
            (rs, row) -> AnnouncementDto.builder()
                .id(rs.getLong("id"))
                .title(rs.getString("title"))
                .content(rs.getString("content"))
                .targetRole(rs.getString("target_role"))
                .authorName(rs.getString("author_name"))
                .createdAt(rs.getTimestamp("created_at").toLocalDateTime())
                .build(),
            userRole
        );
    }

    // ── Tekil duyuru detayı ────────────────────────────────────────────────

    public AnnouncementDto getById(Long id) {
        return jdbc.queryForObject(
            """
            SELECT a.id, a.title, a.content, a.target_role, a.created_at,
                   u.first_name || ' ' || u.last_name AS author_name
            FROM announcements a
            LEFT JOIN users u ON u.id = a.author_id
            WHERE a.id = ?
            """,
            (rs, row) -> AnnouncementDto.builder()
                .id(rs.getLong("id"))
                .title(rs.getString("title"))
                .content(rs.getString("content"))
                .targetRole(rs.getString("target_role"))
                .authorName(rs.getString("author_name"))
                .createdAt(rs.getTimestamp("created_at").toLocalDateTime())
                .build(),
            id
        );
    }

    // ── Duyuru sil (soft delete) ──────────────────────────────────────────────

    public int deleteAnnouncement(Long id) {
        return jdbc.update("UPDATE announcements SET is_active = FALSE WHERE id = ?", id);
    }

    // ── Yeni duyuruyu STOMP kanalına yayınla ────────────────────────────────
    // AnnouncementController INSERT yaptıktan sonra çağırır.
    // Trigger zaten notifications'ı oluşturmuştur — biz sadece WebSocket'e basıyoruz.

    public void broadcastNewAnnouncement(Long id, String title, String content,
                                         String targetRole, Long authorId) {
        String authorName;
        try {
            authorName = jdbc.queryForObject(
                "SELECT first_name || ' ' || last_name FROM users WHERE id = ?",
                String.class, authorId);
        } catch (Exception e) {
            authorName = "Sistem";
        }

        AnnouncementDto dto = AnnouncementDto.builder()
            .id(id)
            .title(title)
            .content(content)
            .targetRole(targetRole)
            .authorName(authorName)
            .createdAt(LocalDateTime.now())
            .build();

        // /topic/announcements → tüm STOMP abonelerine anlık iletilir
        messaging.convertAndSend("/topic/announcements", dto);
        log.info("STOMP yayını: duyuru id={}, hedef={}", id, targetRole);
    }

    // ── Duyuru oluştur + WebSocket yayını ──────────────────────────────────

    public AnnouncementDto createAnnouncement(String title, String content,
                                              String targetRole, Long authorId, String authorName) {
        // 1. DB'ye kaydet
        Long newId = jdbc.queryForObject(
            """
            INSERT INTO announcements (title, content, author_id, target_role, is_active, created_at)
            VALUES (?, ?, ?, ?, TRUE, NOW())
            RETURNING id
            """,
            Long.class, title, content, authorId, targetRole
        );

        // 2. DTO oluştur
        AnnouncementDto dto = AnnouncementDto.builder()
            .id(newId)
            .title(title)
            .content(content)
            .targetRole(targetRole)
            .authorName(authorName)
            .createdAt(LocalDateTime.now())
            .build();

        // 3. /topic/announcements kanalına broadcast — tüm bağlı istemciler alır
        messaging.convertAndSend("/topic/announcements", dto);
        log.info("Duyuru yayınlandı: id={}, hedef={}", newId, targetRole);

        return dto;
    }
}
