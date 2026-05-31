package com.campusconnect.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;

import java.io.Serializable;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class TeacherCourseDto implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long   courseId;
    private String courseCode;
    private String courseName;
    private int    credits;
    private String department;
    private int    capacity;
    private String semester;
    private String academicYear;
    private int    enrolledCount;
    private int    availableSeats;
}
