package com.shanhe.portal.mapper;

import org.apache.ibatis.annotations.Select;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public interface StatsMapper {
    @Select("SELECT COALESCE(SUM(total_amount),0) FROM booking_order WHERE status <> 'CANCELLED'")
    BigDecimal revenue();

    @Select("""
            SELECT DATE(created_at) AS day, COUNT(*) AS orderCount, COALESCE(SUM(total_amount),0) AS amount
            FROM booking_order
            WHERE status <> 'CANCELLED' AND created_at >= DATE_SUB(CURDATE(), INTERVAL 13 DAY)
            GROUP BY DATE(created_at)
            ORDER BY day
            """)
    List<Map<String, Object>> orderTrend();

    @Select("""
            SELECT s.name AS name, COUNT(*) AS orderCount
            FROM booking_order o
            JOIN scenic_spot s ON s.id = o.spot_id
            WHERE o.status <> 'CANCELLED'
            GROUP BY s.id, s.name
            ORDER BY orderCount DESC
            LIMIT 8
            """)
    List<Map<String, Object>> topSpots();

    @Select("""
            SELECT DATE(created_at) AS day, COUNT(*) AS cnt
            FROM `user`
            WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 13 DAY)
            GROUP BY DATE(created_at)
            ORDER BY day
            """)
    List<Map<String, Object>> userGrowth();

    @Select("""
            SELECT c.name AS name, COUNT(s.id) AS cnt
            FROM spot_category c
            LEFT JOIN scenic_spot s ON s.category_id = c.id
            GROUP BY c.id, c.name, c.sort_order
            ORDER BY c.sort_order
            """)
    List<Map<String, Object>> categories();
}
