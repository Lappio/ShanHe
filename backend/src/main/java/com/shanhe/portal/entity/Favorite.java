package com.shanhe.portal.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class Favorite {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String targetType;
    private Long targetId;
    private LocalDateTime createdAt;

    @TableField(exist = false)
    private String title;
    @TableField(exist = false)
    private String coverUrl;
    @TableField(exist = false)
    private String subtitle;
    @TableField(exist = false)
    private Boolean available;
}
