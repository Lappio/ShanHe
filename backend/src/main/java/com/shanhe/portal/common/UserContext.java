package com.shanhe.portal.common;

/**
 * 当前请求的登录用户。在拦截器中写入，请求结束时清除。
 */
public final class UserContext {
    private static final ThreadLocal<LoginUser> HOLDER = new ThreadLocal<>();

    private UserContext() {
    }

    public static void set(LoginUser user) {
        HOLDER.set(user);
    }

    public static LoginUser get() {
        return HOLDER.get();
    }

    public static void clear() {
        HOLDER.remove();
    }

    public static LoginUser require() {
        LoginUser user = get();
        if (user == null) {
            throw new BizException(401, "请先登录");
        }
        return user;
    }
}
