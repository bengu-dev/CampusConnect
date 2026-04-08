package com.campusconnect.service;

import com.campusconnect.model.User;
import com.campusconnect.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;

    public Map<String, Object> getUserProfile(String email) {
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("Kullanıcı bulunamadı!"));

        Map<String, Object> profile = new HashMap<>();
        profile.put("id", user.getId());
        profile.put("firstName", user.getFirstName());
        profile.put("lastName", user.getLastName());
        profile.put("email", user.getEmail());
        profile.put("role", user.getRole().name());
        profile.put("fullName", user.getFullName());
        profile.put("createdAt", user.getCreatedAt());
        if (user.getStudentId() != null) profile.put("studentId", user.getStudentId());
        if (user.getStaffId() != null) profile.put("staffId", user.getStaffId());
        if (user.getEmployeeId() != null) profile.put("employeeId", user.getEmployeeId());
        if (user.getDepartment() != null) profile.put("department", user.getDepartment());
        if (user.getPosition() != null) profile.put("position", user.getPosition());
        return profile;
    }
}
