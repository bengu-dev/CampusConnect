package com.campusconnect.security;

import lombok.AllArgsConstructor;
import lombok.Data;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

/**
 * JWT token'dan çözümlenen kimlik bilgisi.
 * UserDetails implemente eder — Spring Security ile tam uyumluluk.
 * Controller'larda UserPrincipal.current() ile erişilir.
 */
@Data
@AllArgsConstructor
public class UserPrincipal implements UserDetails {

    private Long   userId; // users.id (primary key)
    private String email;
    private String role;   // STUDENT | TEACHER | OFFICE

    // ── UserDetails ──────────────────────────────────────────────────────────

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + role));
    }

    @Override public String  getPassword()            { return null;  }
    @Override public String  getUsername()            { return email; }
    @Override public boolean isAccountNonExpired()    { return true;  }
    @Override public boolean isAccountNonLocked()     { return true;  }
    @Override public boolean isCredentialsNonExpired(){ return true;  }
    @Override public boolean isEnabled()              { return true;  }

    // ── SecurityContext helper ────────────────────────────────────────────────

    /**
     * Mevcut isteğin principal'ını döner.
     * Controller'larda: UserPrincipal me = UserPrincipal.current();
     */
    public static UserPrincipal current() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            throw new IllegalStateException("SecurityContext'te kimlik bilgisi bulunamadı!");
        }
        return (UserPrincipal) auth.getPrincipal();
    }

    public boolean isStudent() { return "STUDENT".equals(role); }
    public boolean isTeacher() { return "TEACHER".equals(role); }
    public boolean isOffice()  { return "OFFICE".equals(role);  }
}
