package com.campusconnect.controller;

import com.campusconnect.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * GET /api/schedule/my
 * Token'dan userId ve role alınır, PostgreSQL'e gerçek sorgu atılır.
 * Hardcode veri YOKTUR.
 *
 * STUDENT → enrollments JOIN schedule JOIN courses JOIN users
 * TEACHER → teacher_courses view
 */
@RestController
@RequestMapping("/api/schedule")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ScheduleController {

    private final JdbcTemplate jdbc;

    @GetMapping("/my")
    public ResponseEntity<Map<String, Object>> getMySchedule() {

        UserPrincipal me = UserPrincipal.current();
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("role", me.getRole());
        response.put("userName", fetchUserName(me.getUserId()));

        if (me.isStudent()) {
            // Öğrencinin haftalık ders programı — gerçek SQL sorgusu
            // day_of_week: 1=Pazartesi, 2=Salı, ... 5=Cuma
            List<Map<String, Object>> schedule = jdbc.queryForList(
                """
                SELECT
                    c.id            AS course_id,
                    c.code          AS course_code,
                    c.name          AS course_name,
                    COALESCE(u.first_name || ' ' || u.last_name, 'Bilinmiyor') AS teacher_name,
                    CASE sch.day_of_week
                        WHEN 'MONDAY'    THEN 1
                        WHEN 'TUESDAY'   THEN 2
                        WHEN 'WEDNESDAY' THEN 3
                        WHEN 'THURSDAY'  THEN 4
                        WHEN 'FRIDAY'    THEN 5
                        WHEN 'SATURDAY'  THEN 6
                        ELSE 1
                    END                       AS day_of_week,
                    sch.start_time::text  AS start_time,
                    sch.end_time::text    AS end_time,
                    sch.classroom,
                    sch.building
                FROM enrollments e
                JOIN courses  c   ON c.id   = e.course_id
                JOIN schedule sch ON sch.course_id = c.id
                LEFT JOIN users u ON u.id   = c.teacher_id
                WHERE e.student_id = ?
                ORDER BY day_of_week, sch.start_time
                """,
                me.getUserId()
            );
            response.put("schedule", schedule);

        } else if (me.isTeacher()) {
            // Öğretmenin verdiği dersler — teacher_courses view
            List<Map<String, Object>> courses = jdbc.queryForList(
                """
                SELECT * FROM teacher_courses
                WHERE teacher_id = ?
                ORDER BY course_code
                """,
                me.getUserId()
            );
            response.put("courses", courses);

            // Öğretmenin gün bazlı ders programı (Flutter day-tab görünümü için)
            List<Map<String, Object>> schedule = jdbc.queryForList(
                """
                SELECT
                    c.id            AS course_id,
                    c.code          AS course_code,
                    c.name          AS course_name,
                    CASE sch.day_of_week
                        WHEN 'MONDAY'    THEN 1
                        WHEN 'TUESDAY'   THEN 2
                        WHEN 'WEDNESDAY' THEN 3
                        WHEN 'THURSDAY'  THEN 4
                        WHEN 'FRIDAY'    THEN 5
                        WHEN 'SATURDAY'  THEN 6
                        ELSE 1
                    END                      AS day_of_week,
                    sch.start_time::text AS start_time,
                    sch.end_time::text   AS end_time,
                    sch.classroom,
                    sch.building
                FROM courses c
                JOIN schedule sch ON sch.course_id = c.id
                WHERE c.teacher_id = ?
                ORDER BY day_of_week, sch.start_time
                """,
                me.getUserId()
            );
            response.put("schedule", schedule);

        } else {
            // Ofis personeli için program yok
            response.put("schedule", Collections.emptyList());
        }

        return ResponseEntity.ok(response);
    }

    // Kullanıcı adını DB'den çek
    private String fetchUserName(Long userId) {
        try {
            return jdbc.queryForObject(
                "SELECT first_name || ' ' || last_name FROM users WHERE id = ?",
                String.class, userId
            );
        } catch (Exception e) {
            return "Kullanıcı";
        }
    }
}
