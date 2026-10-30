package com.shanhe.portal.dto;

import com.shanhe.portal.common.PageQuery;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;

@Data
@EqualsAndHashCode(callSuper = true)
public class SpotQuery extends PageQuery {
    private Long categoryId;
    private String province;
    private String keyword;
    private BigDecimal minPrice;
    private BigDecimal maxPrice;
    private String sort;
}
