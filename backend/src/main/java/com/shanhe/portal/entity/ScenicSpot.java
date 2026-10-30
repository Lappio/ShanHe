package com.shanhe.portal.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class ScenicSpot {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long categoryId;
    private String name;
    private String province;
    private String city;
    private String address;
    private BigDecimal longitude;
    private BigDecimal latitude;
    private String openTime;
    private String summary;
    private String detail;
    private String coverUrl;
    private String videoUrl;
    private String videoCredit;
    private BigDecimal priceFrom;
    private BigDecimal rating;
    private Integer visitCount;
    private Integer status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @TableField(exist = false)
    private String categoryName;
    @TableField(exist = false)
    private Boolean favorited;
}
