package com.shanhe.portal.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class Comment {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String targetType;
    private Long targetId;
    private String content;
    private String status;
    private LocalDateTime createdAt;

    @TableField(exist = false)
    private String nickname;
    @TableField(exist = false)
    private String avatar;
}
