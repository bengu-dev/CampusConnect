package com.campusconnect.controller;

import com.campusconnect.model.Course;
import com.campusconnect.model.Role;
import com.campusconnect.service.CourseService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/schedule")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CourseController {
    private final CourseService courseService;

    @GetMapping
    public ResponseEntity<List<Course>> getSchedule(Authentication auth) {
        String roleStr = auth.getAuthorities().stream()
            .map(GrantedAuthority::getAuthority)
            .findFirst()
            .map(a -> a.replace("ROLE_", ""))
            .orElse("STUDENT");
        try {
            return ResponseEntity.ok(courseService.getCoursesByRole(Role.valueOf(roleStr)));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.ok(courseService.getAllCourses());
        }
    }
}
