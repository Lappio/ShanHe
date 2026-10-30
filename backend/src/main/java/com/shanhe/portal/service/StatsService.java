package com.shanhe.portal.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.shanhe.portal.entity.BookingOrder;
import com.shanhe.portal.entity.ScenicSpot;
import com.shanhe.portal.entity.TravelNote;
import com.shanhe.portal.entity.User;
import com.shanhe.portal.mapper.BookingOrderMapper;
import com.shanhe.portal.mapper.ScenicSpotMapper;
import com.shanhe.portal.mapper.StatsMapper;
import com.shanhe.portal.mapper.TravelNoteMapper;
import com.shanhe.portal.mapper.UserMapper;
import com.shanhe.portal.vo.StatsVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 后台首页的四张图：近 14 日订单、热门景点、用户增长、分类占比。
 * 没有订单的日期补 0，避免折线断开。
 */
@Service
@RequiredArgsConstructor
public class StatsService {
    private final StatsMapper statsMapper;
    private final UserMapper userMapper;
    private final ScenicSpotMapper spotMapper;
    private final BookingOrderMapper orderMapper;
    private final TravelNoteMapper noteMapper;

    public StatsVO load() {
        StatsVO vo = new StatsVO();
        vo.setUserCount(userMapper.selectCount(null));
        vo.setSpotCount(spotMapper.selectCount(new LambdaQueryWrapper<ScenicSpot>().eq(ScenicSpot::getStatus, 1)));
        vo.setOrderCount(orderMapper.selectCount(new LambdaQueryWrapper<BookingOrder>().ne(BookingOrder::getStatus, "CANCELLED")));
        vo.setNoteCount(noteMapper.selectCount(new LambdaQueryWrapper<TravelNote>().eq(TravelNote::getStatus, "APPROVED")));
        vo.setPendingNotes(noteMapper.selectCount(new LambdaQueryWrapper<TravelNote>().eq(TravelNote::getStatus, "PENDING")));
        BigDecimal revenue = statsMapper.revenue();
        vo.setRevenue(revenue == null ? BigDecimal.ZERO : revenue);
        vo.setTodayOrders(orderMapper.selectCount(new LambdaQueryWrapper<BookingOrder>()
                .ne(BookingOrder::getStatus, "CANCELLED")
                .ge(BookingOrder::getCreatedAt, LocalDate.now().atStartOfDay())));

        Map<LocalDate, Long> orders = new HashMap<>();
        Map<LocalDate, BigDecimal> amounts = new HashMap<>();
        for (Map<String, Object> row : statsMapper.orderTrend()) {
            LocalDate day = toDate(row.get("day"));
            orders.put(day, toLong(row.get("orderCount")));
            amounts.put(day, toDecimal(row.get("amount")));
        }
        List<String> days = new ArrayList<>();
        List<Long> counts = new ArrayList<>();
        List<BigDecimal> moneys = new ArrayList<>();
        LocalDate start = LocalDate.now().minusDays(13);
        for (int i = 0; i < 14; i++) {
            LocalDate day = start.plusDays(i);
            days.add(day.toString());
            Long count = orders.get(day);
            counts.add(count == null ? 0L : count);
            moneys.add(amounts.getOrDefault(day, BigDecimal.ZERO));
        }
        vo.setTrendDays(days);
        vo.setTrendOrderCounts(counts);
        vo.setTrendAmounts(moneys);

        List<String> topNames = new ArrayList<>();
        List<Long> topCounts = new ArrayList<>();
        for (Map<String, Object> row : statsMapper.topSpots()) {
            topNames.add(String.valueOf(row.get("name")));
            topCounts.add(toLong(row.get("orderCount")));
        }
        vo.setTopSpotNames(topNames);
        vo.setTopSpotCounts(topCounts);

        Map<LocalDate, Long> growth = new HashMap<>();
        for (Map<String, Object> row : statsMapper.userGrowth()) {
            growth.put(toDate(row.get("day")), toLong(first(row, "cnt", "CNT")));
        }
        List<String> growthDays = new ArrayList<>();
        List<Long> growthCounts = new ArrayList<>();
        for (int i = 0; i < 14; i++) {
            LocalDate day = start.plusDays(i);
            growthDays.add(day.toString());
            growthCounts.add(growth.getOrDefault(day, 0L));
        }
        vo.setGrowthDays(growthDays);
        vo.setGrowthCounts(growthCounts);

        List<String> categoryNames = new ArrayList<>();
        List<Long> categoryCounts = new ArrayList<>();
        for (Map<String, Object> row : statsMapper.categories()) {
            categoryNames.add(String.valueOf(row.get("name")));
            categoryCounts.add(toLong(first(row, "cnt", "CNT")));
        }
        vo.setCategoryNames(categoryNames);
        vo.setCategoryCounts(categoryCounts);
        return vo;
    }

    private Object first(Map<String, Object> row, String... keys) {
        for (String key : keys) {
            if (row.containsKey(key)) {
                return row.get(key);
            }
        }
        return row.values().stream().skip(1).findFirst().orElse(0);
    }

    private LocalDate toDate(Object value) {
        if (value instanceof LocalDate date) {
            return date;
        }
        if (value instanceof java.sql.Date date) {
            return date.toLocalDate();
        }
        if (value instanceof java.util.Date date) {
            return date.toInstant().atZone(ZoneId.of("Asia/Shanghai")).toLocalDate();
        }
        return LocalDate.parse(value.toString().substring(0, 10));
    }

    private long toLong(Object value) {
        if (value == null) {
            return 0;
        }
        if (value instanceof Number number) {
            return number.longValue();
        }
        return Long.parseLong(value.toString());
    }

    private BigDecimal toDecimal(Object value) {
        if (value == null) {
            return BigDecimal.ZERO;
        }
        if (value instanceof BigDecimal decimal) {
            return decimal;
        }
        return new BigDecimal(value.toString());
    }
}
