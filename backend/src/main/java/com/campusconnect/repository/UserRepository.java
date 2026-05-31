package com.campusconnect.repository;
import com.campusconnect.model.Role;
import com.campusconnect.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmailAndRole(String email, Role role);
    boolean existsByEmail(String email);
    boolean existsByStudentId(String studentId);
    boolean existsByStaffId(String staffId);
    boolean existsByEmployeeId(String employeeId);
}
