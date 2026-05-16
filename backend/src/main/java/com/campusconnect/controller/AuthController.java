package com.campusconnect.controller;
import com.campusconnect.model.Role;
import com.campusconnect.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;
@RestController @RequestMapping("/api/auth") @RequiredArgsConstructor @CrossOrigin(origins = "*")
public class AuthController {
    private final AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody Map<String, String> req) {
        try {
            return ResponseEntity.ok(authService.login(req.get("email"), req.get("password"), Role.valueOf(req.get("role").toUpperCase())));
        } catch (IllegalArgumentException e) { return error("Geçersiz rol!", HttpStatus.BAD_REQUEST);
        } catch (RuntimeException e) { return error(e.getMessage(), HttpStatus.UNAUTHORIZED); }
    }

    @PostMapping("/register/student")
    public ResponseEntity<Map<String, Object>> registerStudent(@RequestBody Map<String, String> req) {
        try { return ResponseEntity.status(HttpStatus.CREATED).body(authService.registerStudent(req.get("firstName"), req.get("lastName"), req.get("studentId"), req.get("email"), req.get("password")));
        } catch (RuntimeException e) { return error(e.getMessage(), HttpStatus.BAD_REQUEST); }
    }

    @PostMapping("/register/teacher")
    public ResponseEntity<Map<String, Object>> registerTeacher(@RequestBody Map<String, String> req) {
        try { return ResponseEntity.status(HttpStatus.CREATED).body(authService.registerTeacher(req.get("firstName"), req.get("lastName"), req.get("staffId"), req.get("department"), req.get("email"), req.get("password")));
        } catch (RuntimeException e) { return error(e.getMessage(), HttpStatus.BAD_REQUEST); }
    }

    @PostMapping("/register/office")
    public ResponseEntity<Map<String, Object>> registerOffice(@RequestBody Map<String, String> req) {
        try { return ResponseEntity.status(HttpStatus.CREATED).body(authService.registerOffice(req.get("firstName"), req.get("lastName"), req.get("employeeId"), req.get("department"), req.get("position"), req.get("email"), req.get("password")));
        } catch (RuntimeException e) { return error(e.getMessage(), HttpStatus.BAD_REQUEST); }
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<Map<String, Object>> forgotPassword(@RequestBody Map<String, String> req) {
        try { return ResponseEntity.ok(authService.forgotPassword(req.get("email")));
        } catch (RuntimeException e) { return error(e.getMessage(), HttpStatus.BAD_REQUEST); }
    }

    @PostMapping("/reset-password")
    public ResponseEntity<Map<String, Object>> resetPassword(@RequestBody Map<String, String> req) {
        try { return ResponseEntity.ok(authService.resetPassword(req.get("token"), req.get("newPassword")));
        } catch (RuntimeException e) { return error(e.getMessage(), HttpStatus.BAD_REQUEST); }
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> r = new HashMap<>(); r.put("status", "UP"); r.put("message", "CampusConnect Backend çalışıyor!"); return ResponseEntity.ok(r);
    }

    private ResponseEntity<Map<String, Object>> error(String msg, HttpStatus status) {
        Map<String, Object> e = new HashMap<>(); e.put("success", false); e.put("message", msg); return ResponseEntity.status(status).body(e);
    }
}
