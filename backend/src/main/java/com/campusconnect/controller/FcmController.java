package com.campusconnect.controller;

import com.campusconnect.model.Role;
import com.campusconnect.model.User;
import com.campusconnect.repository.UserRepository;
import com.campusconnect.security.JwtUtil;
import com.campusconnect.service.FcmService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/fcm")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class FcmController {

    private final FcmService     fcmService;
    private final UserRepository userRepository;
    private final JwtUtil        jwtUtil;

    /**
     * POST /api/fcm/token
     * Flutter uygulaması, uygulama açılışında FCM token'ını bu endpoint'e kaydeder.
     */
    @PostMapping("/token")
    public ResponseEntity<Map<String, Object>> registerToken(
            @RequestHeader("Authorization") String auth,
            @RequestBody Map<String, String> body) {

        if (auth == null || !auth.startsWith("Bearer ")) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Token eksik!"));
        }

        String jwtToken = auth.substring(7);
        if (!jwtUtil.isTokenValid(jwtToken)) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Geçersiz token!"));
        }

        String email   = jwtUtil.getEmailFromToken(jwtToken);
        String role    = jwtUtil.getRoleFromToken(jwtToken);
        User   user    = userRepository.findByEmailAndRole(email, Role.valueOf(role)).orElse(null);
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Kullanıcı bulunamadı!"));
        }

        String fcmToken = body.get("fcmToken");
        String platform = body.getOrDefault("platform", "ANDROID");

        if (fcmToken == null || fcmToken.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "FCM token boş!"));
        }

        fcmService.saveToken(user.getId(), fcmToken, platform);
        return ResponseEntity.ok(Map.of("success", true, "message", "FCM token kaydedildi."));
    }
}
