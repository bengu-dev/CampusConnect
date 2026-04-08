package com.campusconnect.controller;

import com.campusconnect.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class UserController {
    private final UserService userService;

    @GetMapping("/profile")
    public ResponseEntity<Map<String, Object>> getProfile(Authentication auth) {
        try {
            return ResponseEntity.ok(userService.getUserProfile(auth.getName()));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
}
