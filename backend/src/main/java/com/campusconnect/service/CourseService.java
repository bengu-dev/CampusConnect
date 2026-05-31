package com.campusconnect.service;

import com.campusconnect.dto.StudentInCourseDto;
import com.campusconnect.dto.TeacherCourseDto;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CourseService {

    private final JdbcTemplate jdbc;

    // ── Öğretmenin dersleri ───────────────────────────────────────────────────

    public List<TeacherCourseDto> getTeacherCourses(Long teacherId) {
        return jdbc.query(
            """
            SELECT c.id AS course_id, c.teacher_id, c.code AS course_code, c.name AS course_name,
                   c.credits, c.department, c.capacity, c.semester, c.academic_year,
                   COUNT(e.id) FILTER (WHERE e.status = 'ACTIVE') AS enrolled_count,
                   c.capacity - COUNT(e.id) FILTER (WHERE e.status = 'ACTIVE') AS available_seats
            FROM courses c
            LEFT JOIN enrollments e ON e.course_id = c.id
            WHERE c.teacher_id = ?
            GROUP BY c.id
            ORDER BY c.code
            """,
            (rs, row) -> TeacherCourseDto.builder()
                .courseId(rs.getLong("course_id"))
                .courseCode(rs.getString("course_code"))
                .courseName(rs.getString("course_name"))
                .credits(rs.getInt("credits"))
                .department(rs.getString("department"))
                .capacity(rs.getInt("capacity"))
                .semester(rs.getString("semester"))
                .academicYear(rs.getString("academic_year"))
                .enrolledCount(rs.getInt("enrolled_count"))
                .availableSeats(rs.getInt("available_seats"))
                .build(),
            teacherId
        );
    }

    // ── Bir dersteki öğrenci listesi ─────────────────────────────────────────

    public List<StudentInCourseDto> getStudentsInCourse(Long courseId, Long teacherId) {
        // teacherId kontrolü: sadece dersin sahibi öğretmen görebilir
        int owned = jdbc.queryForObject(
            "SELECT COUNT(*) FROM courses WHERE id = ? AND teacher_id = ?",
            Integer.class, courseId, teacherId);
        if (owned == 0) throw new RuntimeException("Bu derse erişim yetkiniz yok!");

        return jdbc.query(
            """
            SELECT e.id AS enrollment_id, u.id AS user_id,
                   u.first_name, u.last_name, u.student_id AS student_number, u.email,
                   e.grade, e.status AS enrollment_status
            FROM enrollments e
            JOIN users u ON u.id = e.student_id
            WHERE e.course_id = ?
            ORDER BY u.last_name, u.first_name
            """,
            (rs, row) -> StudentInCourseDto.builder()
                .enrollmentId(rs.getLong("enrollment_id"))
                .userId(rs.getLong("user_id"))
                .firstName(rs.getString("first_name"))
                .lastName(rs.getString("last_name"))
                .studentNumber(rs.getString("student_number"))
                .email(rs.getString("email"))
                .grade(rs.getString("grade"))
                .enrollmentStatus(rs.getString("enrollment_status"))
                .build(),
            courseId
        );
    }

    // ── Not girişi / güncelleme ───────────────────────────────────────────────

    public void setGrade(Long enrollmentId, String grade, Long teacherId) {
        // Öğretmenin kendi dersi mi?
        int owned = jdbc.queryForObject(
            """
            SELECT COUNT(*) FROM enrollments e
            JOIN courses c ON c.id = e.course_id
            WHERE e.id = ? AND c.teacher_id = ?
            """,
            Integer.class, enrollmentId, teacherId);
        if (owned == 0) throw new RuntimeException("Bu öğrenciye not girme yetkiniz yok!");

        jdbc.update(
            "UPDATE enrollments SET grade = ? WHERE id = ?",
            grade, enrollmentId);
    }
}
