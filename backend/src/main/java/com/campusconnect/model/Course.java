package com.campusconnect.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "courses")
@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class Course {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false) private String courseName;
    @Column(nullable = false) private String courseCode;
    private String teacherName;
    private String dayOfWeek;
    private String startTime;
    private String endTime;
    private String room;
    private String department;

    @Enumerated(EnumType.STRING)
    private Role targetRole;
}
