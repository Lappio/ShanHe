package com.shanhe.portal.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class ProfileDTO {
    @NotBlank(message = "请输入昵称")
    @Size(max = 20, message = "昵称不超过 20 个字")
    private String nickname;
    @Pattern(regexp = "^$|^1\\d{10}$", message = "手机号格式不正确")
    private String phone;
    @Size(max = 100, message = "邮箱过长")
    private String email;
    @Size(max = 255, message = "头像地址过长")
    private String avatar;
}
