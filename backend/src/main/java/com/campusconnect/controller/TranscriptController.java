package com.campusconnect.controller;

import com.campusconnect.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * GET /api/transcript
 * Sadece STUDENT rolü erişebilir.
 * student_transcript view'ını kullanır — hardcode veri YOKTUR.
 */
@RestController
@RequestMapping("/api/transcript")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class TranscriptController {

    private final JdbcTemplate jdbc;

    /**
     * Öğrencinin tüm ders notlarını döner.
     * student_transcript view: enrollments JOIN courses JOIN users
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getTranscript() {
        UserPrincipal me = UserPrincipal.current();

        if (!me.isStudent()) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(
                Map.of("success", false, "message", "Bu endpoint sadece öğrencilere açıktır!")
            );
        }

        // student_transcript view — student_id = users.id (primary key)
        List<Map<String, Object>> transcript = jdbc.queryForList(
            """
            SELECT *
            FROM student_transcript
            WHERE student_id = ?
            ORDER BY academic_year DESC, semester DESC, course_code ASC
            """,
            me.getUserId()
        );

        // GPA hesapla (letter_grade varsa, değilse grade üzerinden)
        double gpa = calculateGpa(transcript);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("transcript", transcript);
        response.put("totalCourses", transcript.size());
        response.put("gpa", gpa);
        return ResponseEntity.ok(response);
    }

    // Basit GPA hesaplama — 4.0 skala
    private double calculateGpa(List<Map<String, Object>> transcript) {
        if (transcript.isEmpty()) return 0.0;

        Map<String, Double> gradePoints = Map.of(
            "AA", 4.0, "BA", 3.5, "BB", 3.0,
            "CB", 2.5, "CC", 2.0, "DC", 1.5,
            "DD", 1.0, "FF", 0.0
        );

        double totalPoints  = 0;
        int    totalCredits = 0;

        for (Map<String, Object> row : transcript) {
            String letterGrade = row.get("letter_grade") != null
                ? row.get("letter_grade").toString()
                : (row.get("grade") != null ? row.get("grade").toString() : null);

            Object creditsObj = row.get("credits");
            if (letterGrade == null || creditsObj == null) continue;

            Double points  = gradePoints.get(letterGrade.toUpperCase());
            int    credits = ((Number) creditsObj).intValue();

            if (points != null && credits > 0) {
                totalPoints  += points * credits;
                totalCredits += credits;
            }
        }

        if (totalCredits == 0) return 0.0;
        return Math.round((totalPoints / totalCredits) * 100.0) / 100.0;
    }
}
