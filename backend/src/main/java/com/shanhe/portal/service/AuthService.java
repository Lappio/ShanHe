package com.shanhe.portal.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shanhe.portal.common.BizException;
import com.shanhe.portal.common.PageQuery;
import com.shanhe.portal.common.PageResult;
import com.shanhe.portal.common.UserContext;
import com.shanhe.portal.dto.LoginDTO;
import com.shanhe.portal.dto.PasswordDTO;
import com.shanhe.portal.dto.ProfileDTO;
import com.shanhe.portal.dto.RegisterDTO;
import com.shanhe.portal.dto.UserUpdateDTO;
import com.shanhe.portal.entity.User;
import com.shanhe.portal.mapper.UserMapper;
import com.shanhe.portal.security.JwtUtil;
import com.shanhe.portal.vo.LoginVO;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public LoginVO register(RegisterDTO dto) {
        Long exists = userMapper.selectCount(new LambdaQueryWrapper<User>().eq(User::getUsername, dto.getUsername()));
        if (exists != null && exists > 0) {
            throw new BizException("用户名已被占用");
        }
        User user = new User();
        user.setUsername(dto.getUsername().trim());
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setNickname(dto.getNickname().trim());
        user.setPhone(blankToNull(dto.getPhone()));
        user.setRole("USER");
        user.setStatus(1);
        user.setTokenVersion(0);
        userMapper.insert(user);
        return new LoginVO(jwtUtil.create(user), user);
    }

    public LoginVO login(LoginDTO dto) {
        User user = userMapper.selectOne(new LambdaQueryWrapper<User>().eq(User::getUsername, dto.getUsername().trim()));
        if (user == null || !passwordEncoder.matches(dto.getPassword(), user.getPassword())) {
            throw new BizException("用户名或密码错误");
        }
        if (user.getStatus() == null || user.getStatus() != 1) {
            throw new BizException("账号已禁用");
        }
        return new LoginVO(jwtUtil.create(user), user);
    }

    public User me() {
        return requireUser(UserContext.require().getId());
    }

    public User updateProfile(ProfileDTO dto) {
        User user = requireUser(UserContext.require().getId());
        user.setNickname(dto.getNickname().trim());
        user.setPhone(blankToNull(dto.getPhone()));
        user.setEmail(blankToNull(dto.getEmail()));
        user.setAvatar(blankToNull(dto.getAvatar()));
        userMapper.updateById(user);
        return user;
    }

    public void updatePassword(PasswordDTO dto) {
        User user = requireUser(UserContext.require().getId());
        if (!passwordEncoder.matches(dto.getOldPassword(), user.getPassword())) {
            throw new BizException("原密码不正确");
        }
        user.setPassword(passwordEncoder.encode(dto.getNewPassword()));
        int version = user.getTokenVersion() == null ? 0 : user.getTokenVersion();
        user.setTokenVersion(version + 1);
        userMapper.updateById(user);
    }

    public PageResult<User> page(String keyword, long page, long size) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<User>().orderByDesc(User::getCreatedAt);
        if (StringUtils.hasText(keyword)) {
            String text = keyword.trim();
            wrapper.and(w -> w.like(User::getUsername, text)
                    .or().like(User::getNickname, text)
                    .or().like(User::getPhone, text));
        }
        Page<User> result = userMapper.selectPage(new Page<>(PageQuery.clampPage(page), PageQuery.clampSize(size, 10)), wrapper);
        return PageResult.of(result);
    }

    public void adminUpdate(Long id, UserUpdateDTO dto) {
        if (!"USER".equals(dto.getRole()) && !"ADMIN".equals(dto.getRole())) {
            throw new BizException("角色只能是 USER 或 ADMIN");
        }
        User user = requireUser(id);
        if (user.getId().equals(UserContext.require().getId()) && (dto.getStatus() != null && dto.getStatus() == 0)) {
            throw new BizException("不能禁用当前登录的管理员");
        }
        if ("ADMIN".equals(user.getRole()) && "USER".equals(dto.getRole())) {
            long admins = userMapper.selectCount(new LambdaQueryWrapper<User>().eq(User::getRole, "ADMIN").eq(User::getStatus, 1));
            if (admins <= 1) {
                throw new BizException("至少保留一名可用管理员");
            }
        }
        user.setRole(dto.getRole());
        if (dto.getStatus() != null) {
            user.setStatus(dto.getStatus() == 1 ? 1 : 0);
        }
        if (StringUtils.hasText(dto.getNickname())) {
            user.setNickname(dto.getNickname().trim());
        }
        userMapper.updateById(user);
    }

    public User requireUser(Long id) {
        User user = userMapper.selectById(id);
        if (user == null) {
            throw new BizException("用户不存在");
        }
        return user;
    }

    private String blankToNull(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }
}
