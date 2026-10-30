package com.shanhe.portal.security;

import com.shanhe.portal.common.LoginUser;
import com.shanhe.portal.entity.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

@Component
public class JwtUtil {
    private final SecretKey key;
    private final long expireMillis;

    public JwtUtil(@Value("${shanhe.jwt.secret}") String secret,
                   @Value("${shanhe.jwt.expire-hours}") long expireHours) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.expireMillis = expireHours * 3_600_000L;
    }

    public String create(User user) {
        return Jwts.builder()
                .subject(user.getUsername())
                .claim("uid", user.getId())
                .claim("role", user.getRole())
                .claim("ver", user.getTokenVersion() == null ? 0 : user.getTokenVersion())
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + expireMillis))
                .signWith(key)
                .compact();
    }

    public LoginUser parse(String token) {
        Claims claims = Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload();
        LoginUser user = new LoginUser();
        user.setId(Long.valueOf(String.valueOf(claims.get("uid"))));
        user.setUsername(claims.getSubject());
        user.setRole(claims.get("role", String.class));
        Object version = claims.get("ver");
        user.setTokenVersion(version == null ? null : Integer.valueOf(String.valueOf(version)));
        return user;
    }
}
