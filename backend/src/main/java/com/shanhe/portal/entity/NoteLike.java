package com.shanhe.portal.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class NoteLike {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long noteId;
    private Long userId;
    private LocalDateTime createdAt;
}
