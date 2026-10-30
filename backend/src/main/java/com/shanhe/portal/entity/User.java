package com.shanhe.portal.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("`user`")
public class User {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String username;
    @JsonIgnore
    private String password;
    private String nickname;
    private String phone;
    private String email;
    private String avatar;
    private String role;
    private Integer status;
    private Integer tokenVersion;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
