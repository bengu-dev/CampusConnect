package com.campusconnect.controller;

import com.campusconnect.security.UserPrincipal;
import com.campusconnect.service.FcmService;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * Etkinlik endpoint'leri.
 *
 * DÜZELTMELER:
 * - GET  : start_date → start_datetime, ?::date → ?::timestamp (şema ile uyumlu)
 * - POST : "startDate" → "startDatetime" (Flutter'ın gönderdiği key ile eşleşiyor)
 *          ?::date → ?::timestamp (TIMESTAMP sütununa doğru cast)
 * - camelCase alan adları eklendi (Flutter JSON parserı için)
 */
@RestController
@RequestMapping("/api/events")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class EventController {

    private final JdbcTemplate jdbc;
    private final FcmService   fcmService;

    // ── GET /api/events ───────────────────────────────────────────────────────
    // Tüm aktif etkinlikleri döner, is_joined bilgisini de ekler.
    // Düzeltme: start_date → start_datetime, is_joined/participant_count
    //           yanında camelCase alias'lar da eklendi.
    @GetMapping
    public ResponseEntity<Map<String, Object>> getEvents() {
        UserPrincipal me = UserPrincipal.current();

        List<Map<String, Object>> events = jdbc.queryForList(
            """
            SELECT
                e.id,
                e.title,
                e.description,
                e.location,
                e.event_type                                                  AS "eventType",
                e.start_datetime::text                                        AS "startDatetime",
                e.end_datetime::text                                          AS "endDatetime",
                COALESCE(u.first_name || ' ' || u.last_name, 'Organizatör')  AS "organizerName",
                COALESCE(ep_count.cnt, 0)                                     AS "participantCount",
                COALESCE(e.capacity, 100)                                     AS capacity,
                CASE WHEN ep_me.user_id IS NOT NULL THEN TRUE ELSE FALSE END  AS "isJoined"
            FROM events e
            LEFT JOIN users u ON u.id = e.organizer_id
            LEFT JOIN (
                SELECT event_id, COUNT(*) AS cnt
                FROM event_participants
                GROUP BY event_id
            ) ep_count ON ep_count.event_id = e.id
            LEFT JOIN event_participants ep_me
                   ON ep_me.event_id = e.id AND ep_me.user_id = ?
            WHERE e.is_active = TRUE
              AND (e.start_datetime IS NULL
                   OR e.start_datetime >= CURRENT_TIMESTAMP - INTERVAL '1 day')
            ORDER BY e.start_datetime ASC NULLS LAST
            """,
            me.getUserId()
        );

        return ResponseEntity.ok(Map.of("success", true, "events", events));
    }

    // ── POST /api/events/{id}/join ────────────────────────────────────────────
    @PostMapping("/{id}/join")
    public ResponseEntity<Map<String, Object>> joinEvent(@PathVariable Long id) {
        UserPrincipal me = UserPrincipal.current();

        Map<String, Object> event;
        try {
            event = jdbc.queryForMap(
                "SELECT title, COALESCE(capacity, 100) AS capacity FROM events WHERE id = ? AND is_active = TRUE",
                id);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(Map.of("success", false, "message", "Etkinlik bulunamadı!"));
        }

        int count = jdbc.queryForObject(
            "SELECT COUNT(*) FROM event_participants WHERE event_id = ?",
            Integer.class, id);
        int capacity = ((Number) event.get("capacity")).intValue();

        if (count >= capacity) {
            return ResponseEntity.badRequest()
                .body(Map.of("success", false, "message", "Etkinlik kontenjanı doldu!"));
        }

        try {
            jdbc.update("INSERT INTO event_participants (event_id, user_id) VALUES (?, ?)",
                id, me.getUserId());
        } catch (DuplicateKeyException e) {
            return ResponseEntity.badRequest()
                .body(Map.of("success", false, "message", "Zaten bu etkinliğe kayıtlısınız!"));
        }

        String title = event.get("title").toString();
        fcmService.sendToUser(me.getUserId(),
            "Etkinliğe Katıldınız",
            "\"" + title + "\" etkinliğine başarıyla kaydoldunuz.",
            Map.of("type", "EVENT_JOIN", "eventId", String.valueOf(id)));

        return ResponseEntity.ok(Map.of(
            "success", true,
            "message", "Etkinliğe katılım başarılı!",
            "participantCount", count + 1
        ));
    }

    // ── DELETE /api/events/{id}/join ──────────────────────────────────────────
    @DeleteMapping("/{id}/join")
    public ResponseEntity<Map<String, Object>> leaveEvent(@PathVariable Long id) {
        UserPrincipal me = UserPrincipal.current();

        int affected = jdbc.update(
            "DELETE FROM event_participants WHERE event_id = ? AND user_id = ?",
            id, me.getUserId());

        if (affected == 0) {
            return ResponseEntity.badRequest()
                .body(Map.of("success", false, "message", "Bu etkinliğe kayıtlı değilsiniz!"));
        }
        return ResponseEntity.ok(Map.of("success", true, "message", "Etkinlik kaydı iptal edildi."));
    }

    // ── POST /api/events ──────────────────────────────────────────────────────
    // DÜZELTME:
    //   "startDate"    → "startDatetime"  (Flutter create_event_screen ile eşleşiyor)
    //   "endDate"      → "endDatetime"
    //   ?::date        → ?::timestamp     (DB sütunu TIMESTAMP tipinde)
    @PostMapping
    public ResponseEntity<Map<String, Object>> create(@RequestBody Map<String, Object> req) {
        UserPrincipal me = UserPrincipal.current();

        if (!me.isOffice()) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(Map.of("success", false,
                    "message", "Sadece ofis personeli etkinlik oluşturabilir!"));
        }

        String title     = Objects.toString(req.get("title"),         null);
        String desc      = Objects.toString(req.get("description"),   "");
        String location  = Objects.toString(req.get("location"),      "");
        // Flutter create_event_screen "startDatetime" ve "endDatetime" gönderiyor
        String startStr  = Objects.toString(req.get("startDatetime"), null);
        String endStr    = Objects.toString(req.get("endDatetime"),   null);
        String eventType = Objects.toString(req.get("eventType"),     "GENERAL");
        int    capacity  = req.containsKey("capacity")
            ? ((Number) req.get("capacity")).intValue() : 100;

        if (title == null || title.isBlank()) {
            return ResponseEntity.badRequest()
                .body(Map.of("success", false, "message", "Başlık zorunludur!"));
        }
        if (startStr == null) {
            return ResponseEntity.badRequest()
                .body(Map.of("success", false, "message", "Başlangıç tarihi ve saati zorunludur!"));
        }

        try {
            Long newId = jdbc.queryForObject(
                """
                INSERT INTO events
                    (title, description, location,
                     start_datetime, end_datetime,
                     event_type, capacity, organizer_id, is_active, created_at)
                VALUES (?, ?, ?, ?::timestamp, ?::timestamp, ?, ?, ?, TRUE, NOW())
                RETURNING id
                """,
                Long.class,
                title.trim(), desc.trim(), location.trim(),
                startStr,
                (endStr != null && !endStr.isBlank()) ? endStr : null,
                eventType, capacity, me.getUserId()
            );

            return ResponseEntity.status(HttpStatus.CREATED).body(Map.of(
                "success", true,
                "message", "Etkinlik oluşturuldu!",
                "id", newId
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(Map.of("success", false,
                    "message", "Etkinlik oluşturulamadı: " + e.getMessage()));
        }
    }
}
