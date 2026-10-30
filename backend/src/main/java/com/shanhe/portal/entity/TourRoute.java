package com.shanhe.portal.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("route")
public class TourRoute {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String title;
    private Integer days;
    private String coverUrl;
    private String summary;
    private String detail;
    private BigDecimal priceFrom;
    private Integer status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
