package com.shanhe.portal.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class StatsVO {
    private long userCount;
    private long spotCount;
    private long orderCount;
    private long noteCount;
    private long pendingNotes;
    private BigDecimal revenue;
    private long todayOrders;
    private List<String> trendDays;
    private List<Long> trendOrderCounts;
    private List<BigDecimal> trendAmounts;
    private List<String> topSpotNames;
    private List<Long> topSpotCounts;
    private List<String> growthDays;
    private List<Long> growthCounts;
    private List<String> categoryNames;
    private List<Long> categoryCounts;
}
