package com.campusconnect.service;

import com.campusconnect.model.Role;
import com.campusconnect.model.User;
import com.campusconnect.repository.UserRepository;
import com.campusconnect.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/**
 * Kimlik doğrulama ve kayıt işlemleri.
 * Şifreler BCrypt ile hash'lenir, asla düz metin kaydedilmez.
 * Login başarısında userId de token'a eklenir.
 */
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository  userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil         jwtUtil;

    // ── Giriş ─────────────────────────────────────────────────────────────────

    public Map<String, Object> login(String email, String password, Role role) {
        User user = userRepository.findByEmailAndRole(email, role)
            .orElseThrow(() -> new RuntimeException("Kullanıcı bulunamadı!"));

        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new RuntimeException("Hatalı şifre!");
        }

        // userId token'a ekleniyor — JwtFilter bunu okuyarak SecurityContext'e yazar
        String token = jwtUtil.generateToken(user.getEmail(), user.getRole().name(), user.getId());

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("token",   token);
        result.put("name",    user.getFullName());
        result.put("email",   user.getEmail());
        result.put("role",    user.getRole().name());
        result.put("userId",  user.getId());
        result.put("message", "Giriş başarılı!");
        return result;
    }

    // ── Öğrenci Kaydı ────────────────────────────────────────────────────────

    public Map<String, Object> registerStudent(String firstName, String lastName,
                                               String studentId, String email, String password) {
        if (userRepository.existsByEmail(email))
            throw new RuntimeException("Bu e-posta zaten kayıtlı!");
        if (userRepository.existsByStudentId(studentId))
            throw new RuntimeException("Bu öğrenci numarası zaten kayıtlı!");

        userRepository.save(User.builder()
            .firstName(firstName).lastName(lastName)
            .studentId(studentId).email(email)
            .password(passwordEncoder.encode(password))
            .role(Role.STUDENT).build());

        Map<String, Object> r = new HashMap<>();
        r.put("success", true);
        r.put("message", "Kayıt başarılı!");
        return r;
    }

    // ── Öğretim Üyesi Kaydı ──────────────────────────────────────────────────

    public Map<String, Object> registerTeacher(String firstName, String lastName,
                                               String staffId, String department,
                                               String email, String password) {
        if (userRepository.existsByEmail(email))
            throw new RuntimeException("Bu e-posta zaten kayıtlı!");
        if (userRepository.existsByStaffId(staffId))
            throw new RuntimeException("Bu personel numarası zaten kayıtlı!");

        userRepository.save(User.builder()
            .firstName(firstName).lastName(lastName)
            .staffId(staffId).department(department).email(email)
            .password(passwordEncoder.encode(password))
            .role(Role.TEACHER).build());

        Map<String, Object> r = new HashMap<>();
        r.put("success", true);
        r.put("message", "Kayıt başarılı!");
        return r;
    }

    // ── Ofis Personeli Kaydı ─────────────────────────────────────────────────

    public Map<String, Object> registerOffice(String firstName, String lastName,
                                              String employeeId, String department,
                                              String position, String email, String password) {
        if (userRepository.existsByEmail(email))
            throw new RuntimeException("Bu e-posta zaten kayıtlı!");
        if (userRepository.existsByEmployeeId(employeeId))
            throw new RuntimeException("Bu çalışan numarası zaten kayıtlı!");

        userRepository.save(User.builder()
            .firstName(firstName).lastName(lastName)
            .employeeId(employeeId).department(department).position(position).email(email)
            .password(passwordEncoder.encode(password))
            .role(Role.OFFICE).build());

        Map<String, Object> r = new HashMap<>();
        r.put("success", true);
        r.put("message", "Kayıt başarılı!");
        return r;
    }

    // ── Şifre Sıfırlama (placeholder) ────────────────────────────────────────

    public Map<String, Object> forgotPassword(String email) {
        Map<String, Object> r = new HashMap<>();
        r.put("success", true);
        r.put("message", "Şifre sıfırlama bağlantısı e-posta adresinize gönderildi!");
        return r;
    }
}
