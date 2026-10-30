package com.shanhe.portal.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shanhe.portal.common.BizException;
import com.shanhe.portal.common.PageQuery;
import com.shanhe.portal.common.PageResult;
import com.shanhe.portal.common.UserContext;
import com.shanhe.portal.dto.SpotQuery;
import com.shanhe.portal.dto.SpotSaveDTO;
import com.shanhe.portal.dto.TicketSaveDTO;
import com.shanhe.portal.entity.BookingOrder;
import com.shanhe.portal.entity.Comment;
import com.shanhe.portal.entity.Favorite;
import com.shanhe.portal.entity.RouteSpot;
import com.shanhe.portal.entity.ScenicSpot;
import com.shanhe.portal.entity.SpotCategory;
import com.shanhe.portal.entity.SpotImage;
import com.shanhe.portal.entity.TicketType;
import com.shanhe.portal.mapper.BookingOrderMapper;
import com.shanhe.portal.mapper.CommentMapper;
import com.shanhe.portal.mapper.FavoriteMapper;
import com.shanhe.portal.mapper.RouteSpotMapper;
import com.shanhe.portal.mapper.ScenicSpotMapper;
import com.shanhe.portal.mapper.SpotCategoryMapper;
import com.shanhe.portal.mapper.SpotImageMapper;
import com.shanhe.portal.mapper.TicketTypeMapper;
import com.shanhe.portal.security.HomeCache;
import com.shanhe.portal.vo.SpotDetailVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SpotService {
    private final ScenicSpotMapper spotMapper;
    private final SpotCategoryMapper categoryMapper;
    private final SpotImageMapper imageMapper;
    private final TicketTypeMapper ticketMapper;
    private final BookingOrderMapper orderMapper;
    private final RouteSpotMapper routeSpotMapper;
    private final CommentMapper commentMapper;
    private final FavoriteMapper favoriteMapper;
    private final HomeCache homeCache;

    public PageResult<ScenicSpot> page(SpotQuery query, boolean admin) {
        LambdaQueryWrapper<ScenicSpot> wrapper = new LambdaQueryWrapper<>();
        if (!admin) {
            wrapper.eq(ScenicSpot::getStatus, 1);
        } else if (query.getSort() != null && "offline".equals(query.getSort())) {
            wrapper.eq(ScenicSpot::getStatus, 0);
        }
        if (query.getCategoryId() != null) {
            wrapper.eq(ScenicSpot::getCategoryId, query.getCategoryId());
        }
        if (StringUtils.hasText(query.getProvince())) {
            wrapper.eq(ScenicSpot::getProvince, query.getProvince().trim());
        }
        if (StringUtils.hasText(query.getKeyword())) {
            String keyword = query.getKeyword().trim();
            wrapper.and(w -> w.like(ScenicSpot::getName, keyword)
                    .or().like(ScenicSpot::getCity, keyword)
                    .or().like(ScenicSpot::getProvince, keyword));
        }
        if (query.getMinPrice() != null) {
            wrapper.ge(ScenicSpot::getPriceFrom, query.getMinPrice());
        }
        if (query.getMaxPrice() != null) {
            wrapper.le(ScenicSpot::getPriceFrom, query.getMaxPrice());
        }
        String sort = query.getSort() == null ? "hot" : query.getSort();
        switch (sort) {
            case "priceAsc" -> wrapper.orderByAsc(ScenicSpot::getPriceFrom).orderByDesc(ScenicSpot::getId);
            case "priceDesc" -> wrapper.orderByDesc(ScenicSpot::getPriceFrom).orderByDesc(ScenicSpot::getId);
            case "new" -> wrapper.orderByDesc(ScenicSpot::getCreatedAt);
            default -> wrapper.orderByDesc(ScenicSpot::getVisitCount).orderByDesc(ScenicSpot::getId);
        }
        Page<ScenicSpot> page = spotMapper.selectPage(
                new Page<>(query.pageNo(), query.pageSize(admin ? 10 : 9, 50)), wrapper);
        page.getRecords().forEach(spot -> spot.setDetail(null));
        fillCategory(page.getRecords());
        return PageResult.of(page);
    }

    public List<ScenicSpot> hot(int limit) {
        int size = Math.min(Math.max(limit, 1), 12);
        List<ScenicSpot> list = spotMapper.selectList(new LambdaQueryWrapper<ScenicSpot>()
                .eq(ScenicSpot::getStatus, 1)
                .orderByDesc(ScenicSpot::getVisitCount)
                .last("LIMIT " + size));
        list.forEach(spot -> spot.setDetail(null));
        fillCategory(list);
        return list;
    }

    public List<String> provinces() {
        return spotMapper.selectProvinces();
    }

    public List<ScenicSpot> options() {
        return spotMapper.selectList(new LambdaQueryWrapper<ScenicSpot>()
                .select(ScenicSpot::getId, ScenicSpot::getName, ScenicSpot::getProvince, ScenicSpot::getCity)
                .orderByAsc(ScenicSpot::getId));
    }

    public SpotDetailVO detail(Long id, boolean admin) {
        ScenicSpot spot = spotMapper.selectById(id);
        if (spot == null || (!admin && (spot.getStatus() == null || spot.getStatus() != 1))) {
            throw new BizException("景点不存在或已下架");
        }
        if (!admin) {
            spotMapper.update(null, new LambdaUpdateWrapper<ScenicSpot>()
                    .eq(ScenicSpot::getId, id)
                    .setSql("visit_count = visit_count + 1"));
            spot.setVisitCount((spot.getVisitCount() == null ? 0 : spot.getVisitCount()) + 1);
        }
        fillCategory(List.of(spot));
        if (UserContext.get() != null) {
            Long count = favoriteMapper.selectCount(new LambdaQueryWrapper<Favorite>()
                    .eq(Favorite::getUserId, UserContext.get().getId())
                    .eq(Favorite::getTargetType, "SPOT")
                    .eq(Favorite::getTargetId, id));
            spot.setFavorited(count != null && count > 0);
        } else {
            spot.setFavorited(false);
        }
        SpotDetailVO vo = new SpotDetailVO();
        vo.setSpot(spot);
        vo.setImages(imageMapper.selectList(new LambdaQueryWrapper<SpotImage>()
                .eq(SpotImage::getSpotId, id)
                .orderByAsc(SpotImage::getSortOrder)
                .orderByAsc(SpotImage::getId)));
        LambdaQueryWrapper<TicketType> ticketWrapper = new LambdaQueryWrapper<TicketType>()
                .eq(TicketType::getSpotId, id)
                .orderByAsc(TicketType::getPrice);
        if (!admin) {
            ticketWrapper.eq(TicketType::getStatus, 1);
        }
        vo.setTickets(ticketMapper.selectList(ticketWrapper));
        Long comments = commentMapper.selectCount(new LambdaQueryWrapper<Comment>()
                .eq(Comment::getTargetType, "SPOT")
                .eq(Comment::getTargetId, id)
                .eq(Comment::getStatus, "VISIBLE"));
        vo.setCommentCount(comments == null ? 0 : comments);
        return vo;
    }

    @Transactional
    public Long save(SpotSaveDTO dto) {
        if (categoryMapper.selectById(dto.getCategoryId()) == null) {
            throw new BizException("分类不存在");
        }
        ScenicSpot spot = dto.getId() == null ? new ScenicSpot() : spotMapper.selectById(dto.getId());
        if (spot == null) {
            throw new BizException("景点不存在");
        }
        boolean creating = dto.getId() == null;
        spot.setCategoryId(dto.getCategoryId());
        spot.setName(dto.getName().trim());
        spot.setProvince(dto.getProvince().trim());
        spot.setCity(dto.getCity().trim());
        spot.setAddress(dto.getAddress().trim());
        spot.setLongitude(dto.getLongitude());
        spot.setLatitude(dto.getLatitude());
        spot.setOpenTime(dto.getOpenTime());
        spot.setSummary(dto.getSummary().trim());
        spot.setDetail(dto.getDetail());
        spot.setVideoUrl(blank(dto.getVideoUrl()));
        spot.setVideoCredit(blank(dto.getVideoCredit()));
        spot.setPriceFrom(dto.getPriceFrom() == null ? BigDecimal.ZERO : dto.getPriceFrom());
        spot.setRating(dto.getRating() == null ? new BigDecimal("4.5") : dto.getRating());
        spot.setStatus(dto.getStatus() != null && dto.getStatus() == 0 ? 0 : 1);
        if (creating) {
            spot.setVisitCount(0);
        }
        if (dto.getImages() != null && !dto.getImages().isEmpty() && !StringUtils.hasText(dto.getCoverUrl())) {
            spot.setCoverUrl(dto.getImages().get(0).getUrl().trim());
        } else {
            spot.setCoverUrl(blank(dto.getCoverUrl()));
        }
        if (creating) {
            spotMapper.insert(spot);
        } else {
            spotMapper.updateById(spot);
        }
        if (dto.getImages() != null) {
            imageMapper.delete(new LambdaQueryWrapper<SpotImage>().eq(SpotImage::getSpotId, spot.getId()));
            int index = 0;
            for (SpotSaveDTO.ImageItem item : dto.getImages()) {
                SpotImage image = new SpotImage();
                image.setSpotId(spot.getId());
                image.setUrl(item.getUrl().trim());
                image.setCaption(blank(item.getCaption()));
                image.setCredit(blank(item.getCredit()));
                image.setSortOrder(item.getSortOrder() == null ? index : item.getSortOrder());
                imageMapper.insert(image);
                index++;
            }
        }
        refreshPrice(spot.getId());
        homeCache.evict();
        return spot.getId();
    }

    @Transactional
    public void delete(Long id) {
        if (spotMapper.selectById(id) == null) {
            throw new BizException("景点不存在");
        }
        if (orderMapper.selectCount(new LambdaQueryWrapper<BookingOrder>().eq(BookingOrder::getSpotId, id)) > 0) {
            throw new BizException("该景点已有订单，请改为下架");
        }
        if (routeSpotMapper.selectCount(new LambdaQueryWrapper<RouteSpot>().eq(RouteSpot::getSpotId, id)) > 0) {
            throw new BizException("该景点已被路线引用，请先从路线中移除");
        }
        ticketMapper.delete(new LambdaQueryWrapper<TicketType>().eq(TicketType::getSpotId, id));
        commentMapper.delete(new LambdaQueryWrapper<Comment>().eq(Comment::getTargetType, "SPOT").eq(Comment::getTargetId, id));
        favoriteMapper.delete(new LambdaQueryWrapper<Favorite>().eq(Favorite::getTargetType, "SPOT").eq(Favorite::getTargetId, id));
        spotMapper.deleteById(id);
        homeCache.evict();
    }

    public PageResult<TicketType> tickets(Long spotId, long page, long size) {
        LambdaQueryWrapper<TicketType> wrapper = new LambdaQueryWrapper<TicketType>().orderByDesc(TicketType::getId);
        if (spotId != null) {
            wrapper.eq(TicketType::getSpotId, spotId);
        }
        Page<TicketType> result = ticketMapper.selectPage(new Page<>(PageQuery.clampPage(page), PageQuery.clampSize(size, 10)), wrapper);
        fillTicketSpot(result.getRecords());
        return PageResult.of(result);
    }

    @Transactional
    public Long saveTicket(TicketSaveDTO dto) {
        if (spotMapper.selectById(dto.getSpotId()) == null) {
            throw new BizException("景点不存在");
        }
        TicketType ticket = dto.getId() == null ? new TicketType() : ticketMapper.selectById(dto.getId());
        if (ticket == null) {
            throw new BizException("票种不存在");
        }
        Long previousSpotId = dto.getId() == null ? null : ticket.getSpotId();
        if (previousSpotId != null && !previousSpotId.equals(dto.getSpotId())) {
            long used = orderMapper.selectCount(new LambdaQueryWrapper<BookingOrder>().eq(BookingOrder::getTicketTypeId, ticket.getId()));
            if (used > 0) {
                throw new BizException("该票种已有订单，不能改所属景点");
            }
        }
        ticket.setSpotId(dto.getSpotId());
        ticket.setName(dto.getName().trim());
        ticket.setPrice(dto.getPrice());
        ticket.setDescription(dto.getDescription());
        ticket.setDailyStock(dto.getDailyStock());
        ticket.setStatus(dto.getStatus() != null && dto.getStatus() == 0 ? 0 : 1);
        if (dto.getId() == null) {
            ticketMapper.insert(ticket);
        } else {
            ticketMapper.updateById(ticket);
        }
        refreshPrice(ticket.getSpotId());
        if (previousSpotId != null && !previousSpotId.equals(ticket.getSpotId())) {
            refreshPrice(previousSpotId);
        }
        homeCache.evict();
        return ticket.getId();
    }

    public void deleteTicket(Long id) {
        TicketType ticket = ticketMapper.selectById(id);
        if (ticket == null) {
            throw new BizException("票种不存在");
        }
        if (orderMapper.selectCount(new LambdaQueryWrapper<BookingOrder>().eq(BookingOrder::getTicketTypeId, id)) > 0) {
            throw new BizException("该票种已有订单，不能删除");
        }
        ticketMapper.deleteById(id);
        refreshPrice(ticket.getSpotId());
        homeCache.evict();
    }

    public void refreshPrice(Long spotId) {
        List<TicketType> tickets = ticketMapper.selectList(new LambdaQueryWrapper<TicketType>()
                .eq(TicketType::getSpotId, spotId)
                .eq(TicketType::getStatus, 1));
        if (tickets.isEmpty()) {
            spotMapper.update(null, new LambdaUpdateWrapper<ScenicSpot>()
                    .eq(ScenicSpot::getId, spotId)
                    .set(ScenicSpot::getPriceFrom, null));
            return;
        }
        BigDecimal min = tickets.stream().map(TicketType::getPrice).min(Comparator.naturalOrder()).orElse(BigDecimal.ZERO);
        spotMapper.update(null, new LambdaUpdateWrapper<ScenicSpot>()
                .eq(ScenicSpot::getId, spotId)
                .set(ScenicSpot::getPriceFrom, min));
    }

    private void fillCategory(List<ScenicSpot> spots) {
        if (spots.isEmpty()) {
            return;
        }
        Map<Long, String> names = categoryMapper.selectList(null).stream()
                .collect(Collectors.toMap(SpotCategory::getId, SpotCategory::getName));
        spots.forEach(spot -> spot.setCategoryName(names.get(spot.getCategoryId())));
    }

    private void fillTicketSpot(List<TicketType> tickets) {
        if (tickets.isEmpty()) {
            return;
        }
        Map<Long, String> names = spotMapper.selectList(new LambdaQueryWrapper<ScenicSpot>()
                        .select(ScenicSpot::getId, ScenicSpot::getName)).stream()
                .collect(Collectors.toMap(ScenicSpot::getId, ScenicSpot::getName));
        tickets.forEach(ticket -> ticket.setSpotName(names.get(ticket.getSpotId())));
    }

    private String blank(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }
}
