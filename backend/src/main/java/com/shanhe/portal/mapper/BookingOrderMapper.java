package com.shanhe.portal.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shanhe.portal.entity.BookingOrder;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDate;

public interface BookingOrderMapper extends BaseMapper<BookingOrder> {
    /**
     * 锁定读。可重复读下，事务里更早的普通查询已经定下快照，
     * 不加 FOR UPDATE 就看不见另一笔已提交的订单，两笔并发会一起超卖。
     */
    @Select("""
            SELECT COALESCE(SUM(quantity), 0) FROM booking_order
            WHERE ticket_type_id = #{ticketId}
              AND visit_date = #{visitDate}
              AND status <> 'CANCELLED'
            FOR UPDATE
            """)
    int soldQuantity(@Param("ticketId") Long ticketId, @Param("visitDate") LocalDate visitDate);
}
