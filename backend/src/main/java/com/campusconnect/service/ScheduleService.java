package com.campusconnect.service;

import com.campusconnect.dto.ScheduleItemDto;
import com.campusconnect.dto.TeacherCourseDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class ScheduleService {

    private final JdbcTemplate jdbc;

    /**
     * Öğrencinin haftalık ders programını getirir.
     * Cache-aside: Redis'te varsa Redis'ten, yoksa DB'den çekip Redis'e yazar.
     * TTL: 30 dakika (CacheConfig ile tanımlanmış).
     */
    @Cacheable(value = "student_schedule", key = "#studentId")
    public List<ScheduleItemDto> getStudentSchedule(Long studentId) {
        log.debug("Cache MISS — DB'den öğrenci programı çekiliyor, studentId={}", studentId);
        return jdbc.query(
            """
            SELECT course_code, course_name, teacher_name,
                   day_of_week,
                   start_time::text AS start_time,
                   end_time::text   AS end_time,
                   room, building
            FROM student_schedule
            WHERE student_id = ?
            ORDER BY
                CASE day_of_week
                    WHEN 'MONDAY'    THEN 1
                    WHEN 'TUESDAY'   THEN 2
                    WHEN 'WEDNESDAY' THEN 3
                    WHEN 'THURSDAY'  THEN 4
                    WHEN 'FRIDAY'    THEN 5
                    ELSE 6
                END,
                start_time
            """,
            (rs, row) -> ScheduleItemDto.builder()
                .courseCode(rs.getString("course_code"))
                .courseName(rs.getString("course_name"))
                .teacherName(rs.getString("teacher_name"))
                .dayOfWeek(rs.getString("day_of_week"))
                .startTime(rs.getString("start_time"))
                .endTime(rs.getString("end_time"))
                .room(rs.getString("room"))
                .building(rs.getString("building"))
                .build(),
            studentId
        );
    }

    /**
     * Öğretmenin verdiği derslerin listesini getirir.
     * TTL: 30 dakika.
     */
    @Cacheable(value = "teacher_courses", key = "#teacherId")
    public List<TeacherCourseDto> getTeacherCourses(Long teacherId) {
        log.debug("Cache MISS — DB'den öğretmen dersleri çekiliyor, teacherId={}", teacherId);
        return jdbc.query(
            """
            SELECT course_id, course_code, course_name, credits, department,
                   capacity, semester, academic_year, enrolled_count, available_seats
            FROM teacher_courses
            WHERE teacher_id = ?
            ORDER BY course_code
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

    @CacheEvict(value = "student_schedule", key = "#studentId")
    public void evictStudentSchedule(Long studentId) {
        log.debug("Cache evict — öğrenci programı temizlendi, studentId={}", studentId);
    }

    @CacheEvict(value = "teacher_courses", key = "#teacherId")
    public void evictTeacherCourses(Long teacherId) {
        log.debug("Cache evict — öğretmen dersleri temizlendi, teacherId={}", teacherId);
    }
}
