package com.campusconnect.controller;

import com.campusconnect.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Bildirim endpoint'leri.
 * Tüm veriler notifications tablosundan PostgreSQL sorgusuyla gelir.
 * Hardcode veri YOKTUR.
 */
@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class NotificationController {

    private final JdbcTemplate jdbc;

    /**
     * GET /api/notifications/my
     * Token sahibinin bildirimlerini döner — en yeni önce.
     * Okunmamışlar is_read=false olarak işaretlidir.
     */
    @GetMapping("/my")
    public ResponseEntity<Map<String, Object>> getMyNotifications() {
        UserPrincipal me = UserPrincipal.current();

        List<Map<String, Object>> notifications = jdbc.queryForList(
            """
            SELECT
                id,
                title,
                body,
                is_read,
                type,
                reference_id,
                reference_type,
                created_at::text AS created_at
            FROM notifications
            WHERE user_id = ?
            ORDER BY created_at DESC
            LIMIT 100
            """,
            me.getUserId()
        );

        // Okunmamış sayısını da döndür
        long unreadCount = notifications.stream()
            .filter(n -> Boolean.FALSE.equals(n.get("is_read")))
            .count();

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("notifications", notifications);
        response.put("unreadCount", unreadCount);
        return ResponseEntity.ok(response);
    }

    /**
     * PUT /api/notifications/read-all
     * Token sahibinin tüm bildirimlerini okundu işaretler.
     * Tek UPDATE sorgusuyla yapılır — stored procedure kullanılabilir.
     */
    @PutMapping("/read-all")
    public ResponseEntity<Map<String, Object>> markAllRead() {
        UserPrincipal me = UserPrincipal.current();

        // Tek UPDATE sorgusu — sadece token sahibinin bildirimleri etkilenir
        int updated = jdbc.update(
            "UPDATE notifications SET is_read = TRUE WHERE user_id = ? AND is_read = FALSE",
            me.getUserId()
        );

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", updated + " bildirim okundu olarak işaretlendi.");
        response.put("updatedCount", updated);
        return ResponseEntity.ok(response);
    }

    /**
     * PUT /api/notifications/{id}/read
     * Tek bir bildirimi okundu işaretle.
     */
    @PutMapping("/{id}/read")
    public ResponseEntity<Map<String, Object>> markOneRead(@PathVariable Long id) {
        UserPrincipal me = UserPrincipal.current();

        // WHERE user_id = ? güvenlik kontrolü yapar (başkasının bildirimine erişilemez)
        int updated = jdbc.update(
            "UPDATE notifications SET is_read = TRUE WHERE id = ? AND user_id = ?",
            id, me.getUserId()
        );

        if (updated == 0) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(Map.of("success", true, "message", "Bildirim okundu işaretlendi."));
    }
}
