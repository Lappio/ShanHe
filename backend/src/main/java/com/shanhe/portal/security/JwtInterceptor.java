package com.shanhe.portal.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.shanhe.portal.common.LoginUser;
import com.shanhe.portal.common.R;
import com.shanhe.portal.common.UserContext;
import com.shanhe.portal.entity.User;
import com.shanhe.portal.mapper.UserMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * 解析 Authorization 头。公开的 GET 允许匿名；写操作、个人数据和 /api/admin 需要登录。
 */
@Component
@RequiredArgsConstructor
public class JwtInterceptor implements HandlerInterceptor {
    private final JwtUtil jwtUtil;
    private final UserMapper userMapper;
    private final ObjectMapper objectMapper;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }
        String header = request.getHeader("Authorization");
        if (header != null && header.startsWith("Bearer ")) {
            String token = header.substring(7).trim();
            if (!token.isEmpty()) {
                try {
                    LoginUser parsed = jwtUtil.parse(token);
                    User db = userMapper.selectById(parsed.getId());
                    if (db != null && Integer.valueOf(1).equals(db.getStatus())
                            && parsed.getTokenVersion() != null
                            && parsed.getTokenVersion().equals(db.getTokenVersion() == null ? 0 : db.getTokenVersion())) {
                        parsed.setRole(db.getRole());
                        parsed.setUsername(db.getUsername());
                        UserContext.set(parsed);
                    } else {
                        UserContext.clear();
                    }
                } catch (Exception ignored) {
                    UserContext.clear();
                }
            }
        }
        String uri = request.getRequestURI();
        boolean admin = uri.startsWith("/api/admin");
        if ((admin || requiresLogin(request)) && UserContext.get() == null) {
            write(response, 401, "请先登录");
            return false;
        }
        LoginUser user = UserContext.get();
        if (admin && (user == null || !"ADMIN".equals(user.getRole()))) {
            write(response, 403, "需要管理员权限");
            return false;
        }
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        UserContext.clear();
    }

    private boolean requiresLogin(HttpServletRequest request) {
        String method = request.getMethod();
        String uri = request.getRequestURI();
        if (uri.startsWith("/api/user") || uri.startsWith("/api/orders") || uri.startsWith("/api/favorites")) {
            return true;
        }
        if ("/api/auth/me".equals(uri) || "/api/notes/mine".equals(uri)) {
            return true;
        }
        if (uri.startsWith("/api/notes") && !"GET".equals(method)) {
            return true;
        }
        return uri.startsWith("/api/comments") && !"GET".equals(method);
    }

    private void write(HttpServletResponse response, int status, String message) throws Exception {
        UserContext.clear();
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(objectMapper.writeValueAsString(R.fail(status, message)));
    }
}
