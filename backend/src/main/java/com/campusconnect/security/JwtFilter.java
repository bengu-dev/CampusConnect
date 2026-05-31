package com.campusconnect.security;

import com.campusconnect.model.Role;
import com.campusconnect.repository.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

/**
 * Her istekte JWT token'ı doğrular.
 * Token geçerliyse userId + email + role bilgisini SecurityContext'e yazar.
 * Controller'lar bu bilgiye UserPrincipal.current() ile erişir.
 */
@Component
@RequiredArgsConstructor
public class JwtFilter extends OncePerRequestFilter {

    private final JwtUtil        jwtUtil;
    private final UserRepository userRepository;

    @Override
    protected void doFilterInternal(HttpServletRequest req,
                                    HttpServletResponse res,
                                    FilterChain chain)
            throws ServletException, IOException {

        String header = req.getHeader("Authorization");

        if (header != null && header.startsWith("Bearer ")) {
            String token = header.substring(7);

            if (jwtUtil.isTokenValid(token)) {
                String email  = jwtUtil.getEmailFromToken(token);
                String role   = jwtUtil.getRoleFromToken(token);
                Long   userId = jwtUtil.getUserIdFromToken(token);

                // userId token'da yoksa (eski token) DB'den çek
                if (userId == null) {
                    userId = userRepository
                        .findByEmailAndRole(email, Role.valueOf(role))
                        .map(u -> u.getId())
                        .orElse(null);
                }

                if (userId != null) {
                    UserPrincipal principal = new UserPrincipal(userId, email, role);

                    UsernamePasswordAuthenticationToken auth =
                        new UsernamePasswordAuthenticationToken(
                            principal,
                            null,
                            List.of(new SimpleGrantedAuthority("ROLE_" + role))
                        );

                    SecurityContextHolder.getContext().setAuthentication(auth);
                }
            }
        }

        chain.doFilter(req, res);
    }
}
