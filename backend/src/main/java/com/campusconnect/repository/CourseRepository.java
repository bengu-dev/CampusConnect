package com.campusconnect.repository;

import com.campusconnect.model.Course;
import com.campusconnect.model.Role;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CourseRepository extends JpaRepository<Course, Long> {
    @Query("SELECT c FROM Course c WHERE c.targetRole = :role OR c.targetRole IS NULL")
    List<Course> findByRoleOrAll(Role role);
}
