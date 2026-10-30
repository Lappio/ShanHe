package com.shanhe.portal.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class UserUpdateDTO {
    @NotBlank(message = "请选择角色")
    private String role;
    private Integer status;
    private String nickname;
}
