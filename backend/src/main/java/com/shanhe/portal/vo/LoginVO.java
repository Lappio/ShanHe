package com.shanhe.portal.vo;

import com.shanhe.portal.entity.User;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class LoginVO {
    private String token;
    private User user;
}
