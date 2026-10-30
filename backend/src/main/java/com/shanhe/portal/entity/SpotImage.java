package com.shanhe.portal.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;

@Data
public class SpotImage {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long spotId;
    private String url;
    private String caption;
    private String credit;
    private Integer sortOrder;
}
