package com.shanhe.portal.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shanhe.portal.common.BizException;
import com.shanhe.portal.common.PageQuery;
import com.shanhe.portal.common.PageResult;
import com.shanhe.portal.common.UserContext;
import com.shanhe.portal.dto.RouteSaveDTO;
import com.shanhe.portal.entity.Favorite;
import com.shanhe.portal.entity.RouteSpot;
import com.shanhe.portal.entity.ScenicSpot;
import com.shanhe.portal.entity.TourRoute;
import com.shanhe.portal.mapper.FavoriteMapper;
import com.shanhe.portal.mapper.RouteSpotMapper;
import com.shanhe.portal.mapper.ScenicSpotMapper;
import com.shanhe.portal.mapper.TourRouteMapper;
import com.shanhe.portal.security.HomeCache;
import com.shanhe.portal.vo.RouteDetailVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RouteService {
    private final TourRouteMapper routeMapper;
    private final RouteSpotMapper routeSpotMapper;
    private final ScenicSpotMapper spotMapper;
    private final FavoriteMapper favoriteMapper;
    private final HomeCache homeCache;

    public PageResult<TourRoute> page(String keyword, boolean admin, long page, long size) {
        LambdaQueryWrapper<TourRoute> wrapper = new LambdaQueryWrapper<>();
        if (!admin) {
            wrapper.eq(TourRoute::getStatus, 1);
        }
        if (StringUtils.hasText(keyword)) {
            wrapper.like(TourRoute::getTitle, keyword.trim());
        }
        wrapper.orderByAsc(TourRoute::getId);
        Page<TourRoute> result = routeMapper.selectPage(new Page<>(PageQuery.clampPage(page), PageQuery.clampSize(size, 10)), wrapper);
        result.getRecords().forEach(route -> route.setDetail(null));
        return PageResult.of(result);
    }

    public List<TourRoute> recommend(int limit) {
        List<TourRoute> list = routeMapper.selectList(new LambdaQueryWrapper<TourRoute>()
                .eq(TourRoute::getStatus, 1)
                .orderByAsc(TourRoute::getId)
                .last("LIMIT " + Math.min(Math.max(limit, 1), 8)));
        list.forEach(route -> route.setDetail(null));
        return list;
    }

    public RouteDetailVO detail(Long id, boolean admin) {
        TourRoute route = routeMapper.selectById(id);
        if (route == null || (!admin && (route.getStatus() == null || route.getStatus() != 1))) {
            throw new BizException("路线不存在或已下线");
        }
        List<RouteSpot> stops = routeSpotMapper.selectList(new LambdaQueryWrapper<RouteSpot>()
                .eq(RouteSpot::getRouteId, id)
                .orderByAsc(RouteSpot::getDayNo)
                .orderByAsc(RouteSpot::getSortOrder));
        if (!stops.isEmpty()) {
            Map<Long, ScenicSpot> spots = spotMapper.selectBatchIds(stops.stream().map(RouteSpot::getSpotId).collect(Collectors.toSet()))
                    .stream().collect(Collectors.toMap(ScenicSpot::getId, spot -> spot));
            for (RouteSpot stop : stops) {
                ScenicSpot spot = spots.get(stop.getSpotId());
                if (spot != null) {
                    stop.setSpotName(spot.getName());
                    stop.setCoverUrl(spot.getCoverUrl());
                    stop.setProvince(spot.getProvince());
                    stop.setCity(spot.getCity());
                    stop.setPriceFrom(spot.getPriceFrom());
                }
            }
        }
        RouteDetailVO vo = new RouteDetailVO();
        vo.setRoute(route);
        vo.setStops(stops);
        if (UserContext.get() != null) {
            Long count = favoriteMapper.selectCount(new LambdaQueryWrapper<Favorite>()
                    .eq(Favorite::getUserId, UserContext.get().getId())
                    .eq(Favorite::getTargetType, "ROUTE")
                    .eq(Favorite::getTargetId, id));
            vo.setFavorited(count != null && count > 0);
        }
        return vo;
    }

    @Transactional
    public Long save(RouteSaveDTO dto) {
        TourRoute route = dto.getId() == null ? new TourRoute() : routeMapper.selectById(dto.getId());
        if (route == null) {
            throw new BizException("路线不存在");
        }
        route.setTitle(dto.getTitle().trim());
        route.setDays(dto.getDays());
        route.setSummary(dto.getSummary().trim());
        route.setDetail(dto.getDetail());
        route.setPriceFrom(dto.getPriceFrom() == null ? BigDecimal.ZERO : dto.getPriceFrom());
        route.setStatus(dto.getStatus() != null && dto.getStatus() == 0 ? 0 : 1);
        route.setCoverUrl(StringUtils.hasText(dto.getCoverUrl()) ? dto.getCoverUrl().trim() : null);
        for (RouteSaveDTO.StopItem item : dto.getStops()) {
            if (item.getDayNo() == null || item.getDayNo() < 1 || item.getDayNo() > dto.getDays()) {
                throw new BizException("站点天数必须在 1 到行程天数之间");
            }
            if (spotMapper.selectById(item.getSpotId()) == null) {
                throw new BizException("路线中包含不存在的景点");
            }
        }
        if (dto.getId() == null) {
            routeMapper.insert(route);
        } else {
            routeMapper.updateById(route);
            routeSpotMapper.delete(new LambdaQueryWrapper<RouteSpot>().eq(RouteSpot::getRouteId, route.getId()));
        }
        int index = 1;
        for (RouteSaveDTO.StopItem item : dto.getStops()) {
            if (spotMapper.selectById(item.getSpotId()) == null) {
                throw new BizException("路线中包含不存在的景点");
            }
            RouteSpot stop = new RouteSpot();
            stop.setRouteId(route.getId());
            stop.setSpotId(item.getSpotId());
            stop.setDayNo(item.getDayNo());
            stop.setSortOrder(item.getSortOrder() == null ? index : item.getSortOrder());
            stop.setStayNote(item.getStayNote());
            routeSpotMapper.insert(stop);
            index++;
        }
        if (!StringUtils.hasText(route.getCoverUrl())) {
            ScenicSpot first = spotMapper.selectById(dto.getStops().get(0).getSpotId());
            if (first != null) {
                route.setCoverUrl(first.getCoverUrl());
                routeMapper.updateById(route);
            }
        }
        homeCache.evict();
        return route.getId();
    }

    @Transactional
    public void delete(Long id) {
        if (routeMapper.selectById(id) == null) {
            throw new BizException("路线不存在");
        }
        favoriteMapper.delete(new LambdaQueryWrapper<Favorite>().eq(Favorite::getTargetType, "ROUTE").eq(Favorite::getTargetId, id));
        routeMapper.deleteById(id);
        homeCache.evict();
    }
}
