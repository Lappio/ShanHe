package com.shanhe.portal.controller;

import com.shanhe.portal.common.R;
import com.shanhe.portal.dto.LoginDTO;
import com.shanhe.portal.dto.PasswordDTO;
import com.shanhe.portal.dto.ProfileDTO;
import com.shanhe.portal.dto.RegisterDTO;
import com.shanhe.portal.entity.User;
import com.shanhe.portal.service.AuthService;
import com.shanhe.portal.vo.LoginVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;

    @PostMapping("/auth/register")
    public R<LoginVO> register(@Valid @RequestBody RegisterDTO dto) {
        return R.ok(authService.register(dto));
    }

    @PostMapping("/auth/login")
    public R<LoginVO> login(@Valid @RequestBody LoginDTO dto) {
        return R.ok(authService.login(dto));
    }

    @GetMapping("/auth/me")
    public R<User> me() {
        return R.ok(authService.me());
    }

    @PutMapping("/user/profile")
    public R<User> profile(@Valid @RequestBody ProfileDTO dto) {
        return R.ok(authService.updateProfile(dto));
    }

    @PutMapping("/user/password")
    public R<Void> password(@Valid @RequestBody PasswordDTO dto) {
        authService.updatePassword(dto);
        return R.ok();
    }

    @GetMapping("/health")
    public R<String> health() {
        return R.ok("山河纪");
    }
}
