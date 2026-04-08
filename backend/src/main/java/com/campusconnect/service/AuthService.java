package com.campusconnect.service;

import com.campusconnect.model.PasswordResetToken;
import com.campusconnect.model.Role;
import com.campusconnect.model.User;
import com.campusconnect.repository.PasswordResetTokenRepository;
import com.campusconnect.repository.UserRepository;
import com.campusconnect.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.*;

@Service @RequiredArgsConstructor
public class AuthService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final PasswordResetTokenRepository passwordResetTokenRepository;

    public Map<String, Object> login(String email, String password, Role role) {
        User user = userRepository.findByEmailAndRole(email, role)
            .orElseThrow(() -> new RuntimeException("Kullanıcı bulunamadı!"));
        if (!passwordEncoder.matches(password, user.getPassword()))
            throw new RuntimeException("Hatalı şifre!");
        String token = jwtUtil.generateToken(user.getEmail(), user.getRole().name());
        Map<String, Object> result = new HashMap<>();
        result.put("success", true); result.put("token", token);
        result.put("name", user.getFullName()); result.put("email", user.getEmail());
        result.put("role", user.getRole().name()); result.put("message", "Giriş başarılı!");
        return result;
    }

    public Map<String, Object> registerStudent(String firstName, String lastName, String studentId, String email, String password) {
        if (userRepository.existsByEmail(email)) throw new RuntimeException("Bu email zaten kayıtlı!");
        if (userRepository.existsByStudentId(studentId)) throw new RuntimeException("Bu öğrenci numarası zaten kayıtlı!");
        userRepository.save(User.builder().firstName(firstName).lastName(lastName)
            .studentId(studentId).email(email).password(passwordEncoder.encode(password)).role(Role.STUDENT).build());
        Map<String, Object> r = new HashMap<>(); r.put("success", true); r.put("message", "Kayıt başarılı!"); return r;
    }

    public Map<String, Object> registerTeacher(String firstName, String lastName, String staffId, String department, String email, String password) {
        if (userRepository.existsByEmail(email)) throw new RuntimeException("Bu email zaten kayıtlı!");
        if (userRepository.existsByStaffId(staffId)) throw new RuntimeException("Bu personel numarası zaten kayıtlı!");
        userRepository.save(User.builder().firstName(firstName).lastName(lastName)
            .staffId(staffId).department(department).email(email).password(passwordEncoder.encode(password)).role(Role.TEACHER).build());
        Map<String, Object> r = new HashMap<>(); r.put("success", true); r.put("message", "Kayıt başarılı!"); return r;
    }

    public Map<String, Object> registerOffice(String firstName, String lastName, String employeeId, String department, String position, String email, String password) {
        if (userRepository.existsByEmail(email)) throw new RuntimeException("Bu email zaten kayıtlı!");
        if (userRepository.existsByEmployeeId(employeeId)) throw new RuntimeException("Bu çalışan numarası zaten kayıtlı!");
        userRepository.save(User.builder().firstName(firstName).lastName(lastName)
            .employeeId(employeeId).department(department).position(position)
            .email(email).password(passwordEncoder.encode(password)).role(Role.OFFICE).build());
        Map<String, Object> r = new HashMap<>(); r.put("success", true); r.put("message", "Kayıt başarılı!"); return r;
    }

    @Transactional
    public Map<String, Object> forgotPassword(String email) {
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("Bu email ile kayıtlı kullanıcı bulunamadı!"));
        passwordResetTokenRepository.deleteByUser_Id(user.getId());
        String token = UUID.randomUUID().toString();
        passwordResetTokenRepository.save(PasswordResetToken.builder()
            .token(token).user(user)
            .expiryDate(LocalDateTime.now().plusHours(1))
            .used(false).build());
        Map<String, Object> r = new HashMap<>();
        r.put("success", true);
        r.put("message", "Şifre sıfırlama linki gönderildi!");
        r.put("resetToken", token); // Gerçek uygulamada bu token email ile gönderilir
        return r;
    }

    @Transactional
    public Map<String, Object> resetPassword(String token, String newPassword) {
        PasswordResetToken resetToken = passwordResetTokenRepository.findByToken(token)
            .orElseThrow(() -> new RuntimeException("Geçersiz token!"));
        if (resetToken.isExpired()) throw new RuntimeException("Token süresi dolmuş!");
        if (resetToken.isUsed()) throw new RuntimeException("Token daha önce kullanılmış!");
        User user = resetToken.getUser();
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
        resetToken.setUsed(true);
        passwordResetTokenRepository.save(resetToken);
        Map<String, Object> r = new HashMap<>();
        r.put("success", true); r.put("message", "Şifreniz başarıyla güncellendi!");
        return r;
    }
}
