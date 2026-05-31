package com.campusconnect.service;

import com.campusconnect.dto.EventDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class EventService {

    private final JdbcTemplate jdbc;
    private final FcmService   fcmService;

    // ── Etkinlik listesi ──────────────────────────────────────────────────────

    public List<EventDto> getUpcomingEvents(Long userId) {
        return jdbc.query(
            """
            SELECT e.id, e.title, e.description, e.location,
                   e.start_datetime, e.end_datetime, e.event_type,
                   e.capacity, e.is_active, e.created_at,
                   u.first_name || ' ' || u.last_name AS organizer_name,
                   COUNT(ep.id)                        AS participant_count,
                   EXISTS(SELECT 1 FROM event_participants ep2
                          WHERE ep2.event_id = e.id AND ep2.user_id = ?) AS is_joined
            FROM events e
            LEFT JOIN users u              ON u.id = e.organizer_id
            LEFT JOIN event_participants ep ON ep.event_id = e.id
            WHERE e.is_active = TRUE
            GROUP BY e.id, u.first_name, u.last_name
            ORDER BY e.start_datetime ASC
            """,
            (rs, row) -> EventDto.builder()
                .id(rs.getLong("id"))
                .title(rs.getString("title"))
                .description(rs.getString("description"))
                .location(rs.getString("location"))
                .startDatetime(rs.getTimestamp("start_datetime").toLocalDateTime())
                .endDatetime(rs.getTimestamp("end_datetime") != null
                    ? rs.getTimestamp("end_datetime").toLocalDateTime() : null)
                .eventType(rs.getString("event_type"))
                .organizerName(rs.getString("organizer_name"))
                .participantCount(rs.getInt("participant_count"))
                .capacity(rs.getInt("capacity"))
                .isJoined(rs.getBoolean("is_joined"))
                .isActive(rs.getBoolean("is_active"))
                .createdAt(rs.getTimestamp("created_at").toLocalDateTime())
                .build(),
            userId
        );
    }

    // ── Etkinliğe katıl ───────────────────────────────────────────────────────

    public Map<String, Object> joinEvent(Long eventId, Long userId) {
        // Kapasite kontrolü
        int count = jdbc.queryForObject(
            "SELECT COUNT(*) FROM event_participants WHERE event_id = ?",
            Integer.class, eventId);
        int capacity = jdbc.queryForObject(
            "SELECT capacity FROM events WHERE id = ?",
            Integer.class, eventId);

        if (count >= capacity) {
            throw new RuntimeException("Etkinlik kontenjanı doldu!");
        }

        try {
            jdbc.update(
                "INSERT INTO event_participants (event_id, user_id) VALUES (?, ?)",
                eventId, userId);
        } catch (DuplicateKeyException e) {
            throw new RuntimeException("Zaten bu etkinliğe kayıtlısınız!");
        }

        // Katılan kullanıcıya bildirim
        String eventTitle = jdbc.queryForObject(
            "SELECT title FROM events WHERE id = ?", String.class, eventId);

        fcmService.sendToUser(userId,
            "Etkinliğe Katıldınız",
            "\"" + eventTitle + "\" etkinliğine başarıyla kaydoldunuz.",
            Map.of("type", "EVENT_JOIN", "eventId", String.valueOf(eventId)));

        return Map.of("success", true,
            "message", "Etkinliğe katılım başarılı!",
            "participantCount", count + 1);
    }

    // ── Etkinlikten ayrıl ─────────────────────────────────────────────────────

    public Map<String, Object> leaveEvent(Long eventId, Long userId) {
        int affected = jdbc.update(
            "DELETE FROM event_participants WHERE event_id = ? AND user_id = ?",
            eventId, userId);
        if (affected == 0) throw new RuntimeException("Bu etkinliğe kayıtlı değilsiniz!");
        return Map.of("success", true, "message", "Etkinlik kaydı iptal edildi.");
    }

    // ── Etkinlik oluştur ─────────────────────────────────────────────────────

    public EventDto createEvent(String title, String description, String location,
                                LocalDateTime startDt, LocalDateTime endDt,
                                String eventType, int capacity, Long organizerId) {
        Long id = jdbc.queryForObject(
            """
            INSERT INTO events (title, description, location, start_datetime, end_datetime,
                                event_type, capacity, organizer_id, is_active, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, TRUE, NOW())
            RETURNING id
            """,
            Long.class, title, description, location, startDt, endDt,
            eventType, capacity, organizerId);

        return EventDto.builder()
            .id(id)
            .title(title)
            .description(description)
            .location(location)
            .startDatetime(startDt)
            .endDatetime(endDt)
            .eventType(eventType)
            .capacity(capacity)
            .participantCount(0)
            .isJoined(false)
            .isActive(true)
            .createdAt(LocalDateTime.now())
            .build();
    }
}
