package com.campusconnect.controller;

import com.campusconnect.model.Role;
import com.campusconnect.model.User;
import com.campusconnect.repository.UserRepository;
import com.campusconnect.security.JwtUtil;
import com.campusconnect.service.CourseService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/courses")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CourseController {

    private final JdbcTemplate jdbc;

    private final CourseService  courseService;
    private final UserRepository userRepository;
    private final JwtUtil        jwtUtil;

    /** GET /api/courses/students — tüm öğrencilerin listesi (duyuru hedefleme için) */
    @GetMapping("/students/all")
    public ResponseEntity<Map<String, Object>> getAllStudents(
            @RequestHeader("Authorization") String auth) {
        if (resolve(auth) == null) return err("Yetkisiz erişim!");
        List<Map<String, Object>> students = jdbc.queryForList(
            """
            SELECT id, first_name, last_name, student_id, department
            FROM users
            WHERE role = 'STUDENT'
            ORDER BY first_name, last_name
            """
        );
        Map<String, Object> r = new HashMap<>();
        r.put("success", true);
        r.put("students", students);
        return ResponseEntity.ok(r);
    }

    /** GET /api/courses/teachers — tüm öğretmenlerin listesi (duyuru hedefleme için) */
    @GetMapping("/teachers")
    public ResponseEntity<Map<String, Object>> getAllTeachers(
            @RequestHeader("Authorization") String auth) {
        if (resolve(auth) == null) return err("Yetkisiz erişim!");
        List<Map<String, Object>> teachers = jdbc.queryForList(
            """
            SELECT id, first_name, last_name, department, staff_id
            FROM users
            WHERE role = 'TEACHER'
            ORDER BY first_name, last_name
            """
        );
        Map<String, Object> r = new HashMap<>();
        r.put("success", true);
        r.put("teachers", teachers);
        return ResponseEntity.ok(r);
    }

    /** GET /api/courses/my — öğretmenin kendi dersleri */
    @GetMapping("/my")
    public ResponseEntity<Map<String, Object>> getMyCourses(
            @RequestHeader("Authorization") String auth) {
        User user = resolve(auth);
        if (user == null) return err("Yetkisiz erişim!");
        if (user.getRole() != Role.TEACHER) return err("Sadece öğretmenler erişebilir!");

        Map<String, Object> r = new HashMap<>();
        r.put("success", true);
        r.put("courses", courseService.getTeacherCourses(user.getId()));
        return ResponseEntity.ok(r);
    }

    /** GET /api/courses/{courseId}/students — dersteki öğrenci listesi */
    @GetMapping("/{courseId}/students")
    public ResponseEntity<Map<String, Object>> getCourseStudents(
            @PathVariable Long courseId,
            @RequestHeader("Authorization") String auth) {
        User user = resolve(auth);
        if (user == null) return err("Yetkisiz erişim!");
        if (user.getRole() != Role.TEACHER) return err("Sadece öğretmenler erişebilir!");

        try {
            Map<String, Object> r = new HashMap<>();
            r.put("success", true);
            r.put("students", courseService.getStudentsInCourse(courseId, user.getId()));
            return ResponseEntity.ok(r);
        } catch (RuntimeException e) {
            return err(e.getMessage());
        }
    }

    /** POST /api/courses/{courseId}/grade — not giriş / güncelleme */
    @PostMapping("/{courseId}/grade")
    public ResponseEntity<Map<String, Object>> setGrade(
            @PathVariable Long courseId,
            @RequestHeader("Authorization") String auth,
            @RequestBody Map<String, Object> req) {
        User user = resolve(auth);
        if (user == null) return err("Yetkisiz erişim!");
        if (user.getRole() != Role.TEACHER) return err("Sadece öğretmenler not girebilir!");

        Long   enrollmentId = req.get("enrollmentId") != null
            ? Long.parseLong(req.get("enrollmentId").toString()) : null;
        String grade        = req.get("grade") != null ? req.get("grade").toString() : null;

        if (enrollmentId == null) return err("enrollmentId zorunlu!");
        if (grade == null || grade.isBlank()) return err("Not değeri zorunlu!");

        // Geçerli not formatı: AA, BA, BB, CB, CC, DC, DD, FF veya MUAF, DEV
        if (!grade.matches("^(AA|BA|BB|CB|CC|DC|DD|FF|MUAF|DEV|\\d{1,3})$"))
            return err("Geçersiz not formatı! (AA, BA, BB, CB, CC, DC, DD, FF, MUAF, DEV veya sayı)");

        try {
            courseService.setGrade(enrollmentId, grade.trim(), user.getId());
            Map<String, Object> r = new HashMap<>();
            r.put("success", true);
            r.put("message", "Not kaydedildi.");
            return ResponseEntity.ok(r);
        } catch (RuntimeException e) {
            return err(e.getMessage());
        }
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private User resolve(String auth) {
        if (auth == null || !auth.startsWith("Bearer ")) return null;
        String token = auth.substring(7);
        if (!jwtUtil.isTokenValid(token)) return null;
        return userRepository.findByEmailAndRole(
            jwtUtil.getEmailFromToken(token),
            Role.valueOf(jwtUtil.getRoleFromToken(token))).orElse(null);
    }

    private ResponseEntity<Map<String, Object>> err(String msg) {
        return ResponseEntity.badRequest().body(Map.of("success", false, "message", msg));
    }
}
