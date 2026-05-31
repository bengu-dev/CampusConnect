package com.campusconnect.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;

/**
 * JWT token üretme ve doğrulama.
 * Token içeriği: sub=email, role, userId.
 */
@Component
public class JwtUtil {

    @Value("${jwt.secret}")     private String secret;
    @Value("${jwt.expiration}") private long   expiration;

    private Key getKey() {
        return Keys.hmacShaKeyFor(secret.getBytes());
    }

    // userId dahil token üret (yeni standart)
    public String generateToken(String email, String role, Long userId) {
        return Jwts.builder()
            .setSubject(email)
            .claim("role",   role)
            .claim("userId", userId)
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + expiration))
            .signWith(getKey(), SignatureAlgorithm.HS256)
            .compact();
    }

    // Geriye dönük uyumluluk — userId olmadan üretilen eski tokenlar
    public String generateToken(String email, String role) {
        return generateToken(email, role, null);
    }

    public String getEmailFromToken(String token) {
        return getClaims(token).getSubject();
    }

    public String getRoleFromToken(String token) {
        return getClaims(token).get("role", String.class);
    }

    /**
     * Token içinden userId okur.
     * Eski tokenlarda (userId claim yok) null döner —
     * bu durumda controller DB sorgusuyla userId bulur.
     */
    public Long getUserIdFromToken(String token) {
        Object val = getClaims(token).get("userId");
        if (val == null) return null;
        return ((Number) val).longValue();
    }

    public boolean isTokenValid(String token) {
        try {
            getClaims(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    private Claims getClaims(String token) {
        return Jwts.parserBuilder()
            .setSigningKey(getKey())
            .build()
            .parseClaimsJws(token)
            .getBody();
    }
}
