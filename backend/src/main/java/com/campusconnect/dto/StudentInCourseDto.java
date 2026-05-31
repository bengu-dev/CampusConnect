package com.campusconnect.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;
import java.io.Serializable;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class StudentInCourseDto implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long   userId;
    private String firstName;
    private String lastName;
    private String studentNumber;
    private String email;
    private String grade;
    private String enrollmentStatus;
    private Long   enrollmentId;
}
