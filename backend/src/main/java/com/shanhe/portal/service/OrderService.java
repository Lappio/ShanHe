package com.shanhe.portal.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.shanhe.portal.common.BizException;
import com.shanhe.portal.common.PageQuery;
import com.shanhe.portal.common.PageResult;
import com.shanhe.portal.common.UserContext;
import com.shanhe.portal.dto.OrderCreateDTO;
import com.shanhe.portal.entity.BookingOrder;
import com.shanhe.portal.entity.ScenicSpot;
import com.shanhe.portal.entity.TicketType;
import com.shanhe.portal.entity.User;
import com.shanhe.portal.mapper.BookingOrderMapper;
import com.shanhe.portal.mapper.ScenicSpotMapper;
import com.shanhe.portal.mapper.TicketTypeMapper;
import com.shanhe.portal.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ThreadLocalRandom;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrderService {
    private static final DateTimeFormatter ORDER_TIME = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
    private static final ZoneId SHANGHAI = ZoneId.of("Asia/Shanghai");
    private final BookingOrderMapper orderMapper;
    private final TicketTypeMapper ticketMapper;
    private final ScenicSpotMapper spotMapper;
    private final UserMapper userMapper;

    @Transactional
    public BookingOrder create(OrderCreateDTO dto) {
        ScenicSpot spot = spotMapper.selectById(dto.getSpotId());
        if (spot == null || spot.getStatus() == null || spot.getStatus() != 1) {
            throw new BizException("景点不可预约");
        }
        TicketType ticket = ticketMapper.selectById(dto.getTicketTypeId());
        if (ticket == null || ticket.getStatus() == null || ticket.getStatus() != 1) {
            throw new BizException("票种已停售");
        }
        if (!ticket.getSpotId().equals(dto.getSpotId())) {
            throw new BizException("票种与景点不匹配");
        }
        LocalDate today = LocalDate.now(SHANGHAI);
        if (dto.getVisitDate().isBefore(today) || dto.getVisitDate().isAfter(today.plusDays(60))) {
            throw new BizException("游玩日期需在今天起 60 天内");
        }
        TicketType locked = ticketMapper.lockById(ticket.getId());
        if (locked == null || locked.getStatus() == null || locked.getStatus() != 1) {
            throw new BizException("票种已停售");
        }
        int sold = orderMapper.soldQuantity(locked.getId(), dto.getVisitDate());
        if (sold + dto.getQuantity() > locked.getDailyStock()) {
            throw new BizException("当日余票不足，剩余 " + Math.max(locked.getDailyStock() - sold, 0) + " 张");
        }
        BookingOrder order = new BookingOrder();
        order.setOrderNo(nextOrderNo());
        order.setUserId(UserContext.require().getId());
        order.setSpotId(spot.getId());
        order.setTicketTypeId(ticket.getId());
        order.setVisitDate(dto.getVisitDate());
        order.setQuantity(dto.getQuantity());
        order.setUnitPrice(locked.getPrice());
        order.setTotalAmount(locked.getPrice().multiply(BigDecimal.valueOf(dto.getQuantity())));
        order.setContactName(dto.getContactName().trim());
        order.setContactPhone(dto.getContactPhone().trim());
        order.setStatus("PENDING");
        orderMapper.insert(order);
        order.setSpotName(spot.getName());
        order.setSpotCover(spot.getCoverUrl());
        order.setTicketName(ticket.getName());
        return order;
    }

    public PageResult<BookingOrder> mine(String status, long page, long size) {
        LambdaQueryWrapper<BookingOrder> wrapper = new LambdaQueryWrapper<BookingOrder>()
                .eq(BookingOrder::getUserId, UserContext.require().getId())
                .orderByDesc(BookingOrder::getCreatedAt);
        if (StringUtils.hasText(status)) {
            wrapper.eq(BookingOrder::getStatus, status.trim());
        }
        Page<BookingOrder> result = orderMapper.selectPage(new Page<>(PageQuery.clampPage(page), PageQuery.clampSize(size, 10)), wrapper);
        fill(result.getRecords());
        return PageResult.of(result);
    }

    public PageResult<BookingOrder> adminPage(String status, String keyword, long page, long size) {
        LambdaQueryWrapper<BookingOrder> wrapper = new LambdaQueryWrapper<BookingOrder>().orderByDesc(BookingOrder::getCreatedAt);
        if (StringUtils.hasText(status)) {
            wrapper.eq(BookingOrder::getStatus, status.trim());
        }
        if (StringUtils.hasText(keyword)) {
            String text = keyword.trim();
            wrapper.and(w -> w.like(BookingOrder::getOrderNo, text)
                    .or().like(BookingOrder::getContactName, text)
                    .or().like(BookingOrder::getContactPhone, text));
        }
        Page<BookingOrder> result = orderMapper.selectPage(new Page<>(PageQuery.clampPage(page), PageQuery.clampSize(size, 10)), wrapper);
        fill(result.getRecords());
        Set<Long> userIds = result.getRecords().stream().map(BookingOrder::getUserId).collect(Collectors.toSet());
        if (!userIds.isEmpty()) {
            Map<Long, String> names = userMapper.selectBatchIds(userIds).stream()
                    .collect(Collectors.toMap(User::getId, User::getUsername));
            result.getRecords().forEach(order -> order.setUsername(names.get(order.getUserId())));
        }
        return PageResult.of(result);
    }

    public void cancel(Long id) {
        int rows = orderMapper.update(null, new LambdaUpdateWrapper<BookingOrder>()
                .set(BookingOrder::getStatus, "CANCELLED")
                .eq(BookingOrder::getId, id)
                .eq(BookingOrder::getUserId, UserContext.require().getId())
                .eq(BookingOrder::getStatus, "PENDING"));
        if (rows == 0) {
            throw new BizException("只能取消自己的待出行订单");
        }
    }

    public void adminStatus(Long id, String status) {
        if (!"COMPLETED".equals(status) && !"CANCELLED".equals(status)) {
            throw new BizException("只能把待出行订单改为已完成或已取消");
        }
        int rows = orderMapper.update(null, new LambdaUpdateWrapper<BookingOrder>()
                .set(BookingOrder::getStatus, status)
                .eq(BookingOrder::getId, id)
                .eq(BookingOrder::getStatus, "PENDING"));
        if (rows == 0) {
            throw new BizException("只有待出行订单可以变更状态");
        }
    }

    private void fill(List<BookingOrder> orders) {
        if (orders.isEmpty()) {
            return;
        }
        Map<Long, ScenicSpot> spots = spotMapper.selectBatchIds(orders.stream().map(BookingOrder::getSpotId).collect(Collectors.toSet()))
                .stream().collect(Collectors.toMap(ScenicSpot::getId, spot -> spot));
        Map<Long, TicketType> tickets = ticketMapper.selectBatchIds(orders.stream().map(BookingOrder::getTicketTypeId).collect(Collectors.toSet()))
                .stream().collect(Collectors.toMap(TicketType::getId, ticket -> ticket));
        for (BookingOrder order : orders) {
            ScenicSpot spot = spots.get(order.getSpotId());
            if (spot != null) {
                order.setSpotName(spot.getName());
                order.setSpotCover(spot.getCoverUrl());
            }
            TicketType ticket = tickets.get(order.getTicketTypeId());
            if (ticket != null) {
                order.setTicketName(ticket.getName());
            }
        }
    }

    private String nextOrderNo() {
        return "SH" + LocalDateTime.now().format(ORDER_TIME) + ThreadLocalRandom.current().nextInt(1000, 10000);
    }
}
