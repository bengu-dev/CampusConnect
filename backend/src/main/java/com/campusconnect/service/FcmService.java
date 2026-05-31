package com.campusconnect.service;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@Slf4j
@Service
@RequiredArgsConstructor
public class FcmService {

    private final JdbcTemplate jdbc;

    // ── Token kaydet / güncelle ────────────────────────────────────────────────

    public void saveToken(Long userId, String fcmToken, String platform) {
        jdbc.update(
            """
            INSERT INTO device_tokens (user_id, fcm_token, platform, updated_at)
            VALUES (?, ?, ?, NOW())
            ON CONFLICT (fcm_token) DO UPDATE SET user_id = ?, platform = ?, updated_at = NOW()
            """,
            userId, fcmToken, platform, userId, platform);
        log.debug("FCM token kaydedildi, userId={}", userId);
    }

    // ── Kullanıcıya bildirim gönder (tüm cihazları) ─────────────────────────

    public void sendToUser(Long userId, String title, String body, Map<String, String> data) {
        List<String> tokens = jdbc.queryForList(
            "SELECT fcm_token FROM device_tokens WHERE user_id = ?",
            String.class, userId);

        if (tokens.isEmpty()) {
            log.debug("FCM: userId={} için kayıtlı token yok.", userId);
            return;
        }

        tokens.forEach(token -> sendToToken(token, title, body, data));
    }

    // ── Belirli token'a bildirim gönder ──────────────────────────────────────

    public void sendToToken(String token, String title, String body, Map<String, String> data) {
        if (!isFcmAvailable()) return;

        try {
            Message.Builder builder = Message.builder()
                .setToken(token)
                .setNotification(Notification.builder()
                    .setTitle(title)
                    .setBody(body)
                    .build())
                .setAndroidConfig(AndroidConfig.builder()
                    .setPriority(AndroidConfig.Priority.HIGH)
                    .setNotification(AndroidNotification.builder()
                        .setSound("default")
                        .build())
                    .build())
                .setApnsConfig(ApnsConfig.builder()
                    .setAps(Aps.builder()
                        .setSound("default")
                        .setBadge(1)
                        .build())
                    .build());

            if (data != null) builder.putAllData(data);

            String response = FirebaseMessaging.getInstance().sendAsync(builder.build()).get();
            log.debug("FCM gönderildi: {}", response);

        } catch (InterruptedException | ExecutionException e) {
            if (e.getMessage() != null && e.getMessage().contains("UNREGISTERED")) {
                // Token artık geçersiz, temizle
                jdbc.update("DELETE FROM device_tokens WHERE fcm_token = ?", token);
                log.warn("FCM: geçersiz token temizlendi.");
            } else {
                log.error("FCM gönderim hatası: {}", e.getMessage());
            }
        }
    }

    // ── Toplu bildirim ─────────────────────────────────────────────────────────

    public void broadcastToRole(String role, String title, String body, Map<String, String> data) {
        if (!isFcmAvailable()) return;

        List<String> tokens = jdbc.queryForList(
            """
            SELECT dt.fcm_token FROM device_tokens dt
            JOIN users u ON u.id = dt.user_id
            WHERE u.role = ?
            """,
            String.class, role);

        tokens.forEach(t -> sendToToken(t, title, body, data));
        log.info("FCM broadcast: role={}, {} token", role, tokens.size());
    }

    private boolean isFcmAvailable() {
        return FirebaseApp.getApps() != null && !FirebaseApp.getApps().isEmpty();
    }
}
