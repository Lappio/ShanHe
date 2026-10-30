package com.shanhe.portal.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class SpotCategory {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    private String description;
    private String icon;
    private Integer sortOrder;
    private LocalDateTime createdAt;
}
