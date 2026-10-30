package com.shanhe.portal.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class RouteSpot {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long routeId;
    private Long spotId;
    private Integer dayNo;
    private Integer sortOrder;
    private String stayNote;

    @TableField(exist = false)
    private String spotName;
    @TableField(exist = false)
    private String coverUrl;
    @TableField(exist = false)
    private String province;
    @TableField(exist = false)
    private String city;
    @TableField(exist = false)
    private BigDecimal priceFrom;
}
