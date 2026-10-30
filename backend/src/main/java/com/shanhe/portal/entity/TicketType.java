package com.shanhe.portal.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class TicketType {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long spotId;
    private String name;
    private BigDecimal price;
    private String description;
    private Integer dailyStock;
    private Integer status;
    private LocalDateTime createdAt;

    @TableField(exist = false)
    private String spotName;
}
