package com.campusconnect.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;

@Component
public class JwtUtil {

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiration}")
    private long expiration;

    // Gizli anahtarı (Secret Key) oluşturur
    private Key getKey() {
        return Keys.hmacShaKeyFor(secret.getBytes());
    }

    // Token üretirken içine hem email hem de Rol bilgisini (claim) koyar
    public String generateToken(String email, String role) {
        return Jwts.builder()
                .setSubject(email)
                .claim("role", role) // Flutter'ın okuyacağı kritik kısım
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + expiration))
                .signWith(getKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    // Token içinden email bilgisini çeker
    public String getEmailFromToken(String token) {
        return getClaims(token).getSubject();
    }

    // Token içinden Rol bilgisini çeker
    public String getRoleFromToken(String token) {
        return getClaims(token).get("role", String.class);
    }

    // Token'ın süresinin dolup dolmadığını veya geçerli olup olmadığını kontrol eder
    public boolean isTokenValid(String token) {
        try {
            getClaims(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    // Token'ın içindeki tüm verileri (Claims) çözer
    private Claims getClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }
}