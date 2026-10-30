package com.shanhe.portal.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class TravelNote {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private Long spotId;
    private String title;
    private String coverUrl;
    private String content;
    private String status;
    private String rejectReason;
    private Integer likeCount;
    private Integer viewCount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @TableField(exist = false)
    private String authorName;
    @TableField(exist = false)
    private String authorAvatar;
    @TableField(exist = false)
    private String spotName;
    @TableField(exist = false)
    private String excerpt;
    @TableField(exist = false)
    private Boolean liked;
    @TableField(exist = false)
    private Boolean favorited;
}
