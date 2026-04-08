package com.campusconnect.service;

import com.campusconnect.model.Course;
import com.campusconnect.model.Role;
import com.campusconnect.repository.CourseRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CourseService {
    private final CourseRepository courseRepository;

    public List<Course> getCoursesByRole(Role role) {
        return courseRepository.findByRoleOrAll(role);
    }

    public List<Course> getAllCourses() {
        return courseRepository.findAll();
    }
}
