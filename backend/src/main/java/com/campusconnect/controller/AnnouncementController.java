package com.campusconnect.controller;

import com.campusconnect.security.UserPrincipal;
import com.campusconnect.service.AnnouncementService;
import com.campusconnect.service.FcmService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Duyuru endpoint'leri.
 * Tüm veriler PostgreSQL'den gelir.
 * recent_announcements view kullanılır (is_active, tarih filtresi view içinde).
 * Yeni duyuru eklenince trigger otomatik notifications oluşturur — manuel yapılmaz.
 */
@RestController
@RequestMapping("/api/announcements")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AnnouncementController {

    private final JdbcTemplate       jdbc;
    private final AnnouncementService announcementService;
    private final FcmService          fcmService;

    /**
     * GET /api/announcements
     * Token'dan role okunur, recent_announcements view'ından role'e göre filtrelenir.
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAnnouncements() {
        UserPrincipal me = UserPrincipal.current();

        // recent_announcements view: is_active=true ve son 30 günü zaten filtreler
        // Burada sadece role filtresi ekliyoruz
        List<Map<String, Object>> list = jdbc.queryForList(
            """
            SELECT *
            FROM recent_announcements
            WHERE target_role = 'ALL'
               OR target_role = ?
            ORDER BY created_at DESC
            """,
            me.getRole()
        );

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("announcements", list);
        return ResponseEntity.ok(response);
    }

    /**
     * GET /api/announcements/{id}
     * Tek duyuru detayı.
     */
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getById(@PathVariable Long id) {
        UserPrincipal.current(); // kimlik doğrulama kontrolü
        try {
            Map<String, Object> ann = jdbc.queryForMap(
                """
                SELECT a.id, a.title, a.content, a.target_role, a.is_pinned, a.created_at,
                       COALESCE(u.first_name || ' ' || u.last_name, 'Sistem') AS author_name
                FROM announcements a
                LEFT JOIN users u ON u.id = a.author_id
                WHERE a.id = ?
                """,
                id
            );
            return ResponseEntity.ok(Map.of("success", true, "announcement", ann));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(Map.of("success", false, "message", "Duyuru bulunamadı!"));
        }
    }

    /**
     * POST /api/announcements
     * Yeni duyuru oluştur — sadece TEACHER veya OFFICE.
     * Trigger otomatik olarak ilgili kullanıcılara notification ekler.
     * FCM push bildirimi de gönderilir.
     */
    @PostMapping
    public ResponseEntity<Map<String, Object>> create(@RequestBody Map<String, String> req) {
        UserPrincipal me = UserPrincipal.current();
        if (me.isStudent()) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(Map.of("success", false, "message", "Öğrenciler duyuru oluşturamaz!"));
        }

        String title      = req.get("title");
        String content    = req.get("content");
        String targetRole = req.getOrDefault("targetRole", "ALL");

        if (title == null || title.isBlank())
            return ResponseEntity.badRequest()
                .body(Map.of("success", false, "message", "Başlık zorunludur!"));
        if (content == null || content.isBlank())
            return ResponseEntity.badRequest()
                .body(Map.of("success", false, "message", "İçerik zorunludur!"));
        if (!List.of("ALL","STUDENT","TEACHER","OFFICE").contains(targetRole))
            return ResponseEntity.badRequest()
                .body(Map.of("success", false, "message", "Geçersiz hedef kitle!"));

        // announcements tablosuna INSERT — trigger otomatik notification oluşturur
        Long newId = jdbc.queryForObject(
            """
            INSERT INTO announcements (title, content, author_id, target_role, created_at)
            VALUES (?, ?, ?, ?, NOW())
            RETURNING id
            """,
            Long.class,
            title.trim(), content.trim(), me.getUserId(), targetRole
        );

        // FCM push bildirimi gönder (Firebase yoksa sessizce atlanır)
        String fcmTarget = "ALL".equals(targetRole) ? null : targetRole;
        if (fcmTarget != null) {
            fcmService.broadcastToRole(fcmTarget,
                "Yeni Duyuru: " + title.trim(),
                content.trim().substring(0, Math.min(100, content.trim().length())),
                Map.of("type", "ANNOUNCEMENT", "announcementId", String.valueOf(newId)));
        }

        // STOMP WebSocket yayını
        announcementService.broadcastNewAnnouncement(newId, title.trim(), content.trim(),
            targetRole, me.getUserId());

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Duyuru oluşturuldu ve yayınlandı!");
        response.put("id", newId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    /**
     * DELETE /api/announcements/{id}
     * Duyuru sil (soft delete) — sadece OFFICE.
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> delete(@PathVariable Long id) {
        UserPrincipal me = UserPrincipal.current();
        if (!me.isOffice()) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(Map.of("success", false, "message", "Sadece ofis personeli silebilir!"));
        }
        int rows = jdbc.update(
            "UPDATE announcements SET is_active = FALSE WHERE id = ?", id);
        if (rows == 0)
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(Map.of("success", false, "message", "Duyuru bulunamadı!"));
        return ResponseEntity.ok(Map.of("success", true, "message", "Duyuru silindi."));
    }
}
