package com.shanhe.portal.common;

import lombok.Data;

@Data
public class LoginUser {
    private Long id;
    private String username;
    private String role;
    private Integer tokenVersion;
}
