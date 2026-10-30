package com.shanhe.portal.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shanhe.portal.common.BizException;
import com.shanhe.portal.common.PageQuery;
import com.shanhe.portal.common.PageResult;
import com.shanhe.portal.common.UserContext;
import com.shanhe.portal.dto.FavoriteDTO;
import com.shanhe.portal.entity.Favorite;
import com.shanhe.portal.entity.ScenicSpot;
import com.shanhe.portal.entity.TourRoute;
import com.shanhe.portal.entity.TravelNote;
import com.shanhe.portal.mapper.FavoriteMapper;
import com.shanhe.portal.mapper.ScenicSpotMapper;
import com.shanhe.portal.mapper.TourRouteMapper;
import com.shanhe.portal.mapper.TravelNoteMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;

@Service
@RequiredArgsConstructor
public class FavoriteService {
    private final FavoriteMapper favoriteMapper;
    private final ScenicSpotMapper spotMapper;
    private final TourRouteMapper routeMapper;
    private final TravelNoteMapper noteMapper;

    @Transactional
    public boolean toggle(FavoriteDTO dto) {
        String type = dto.getTargetType().trim().toUpperCase();
        ensureTarget(type, dto.getTargetId());
        Long userId = UserContext.require().getId();
        Favorite existing = favoriteMapper.selectOne(new LambdaQueryWrapper<Favorite>()
                .eq(Favorite::getUserId, userId)
                .eq(Favorite::getTargetType, type)
                .eq(Favorite::getTargetId, dto.getTargetId()));
        if (existing != null) {
            favoriteMapper.deleteById(existing.getId());
            return false;
        }
        Favorite favorite = new Favorite();
        favorite.setUserId(userId);
        favorite.setTargetType(type);
        favorite.setTargetId(dto.getTargetId());
        favoriteMapper.insert(favorite);
        return true;
    }

    public PageResult<Favorite> mine(String targetType, long page, long size) {
        LambdaQueryWrapper<Favorite> wrapper = new LambdaQueryWrapper<Favorite>()
                .eq(Favorite::getUserId, UserContext.require().getId())
                .orderByDesc(Favorite::getCreatedAt);
        if (targetType != null && !targetType.isBlank()) {
            wrapper.eq(Favorite::getTargetType, targetType.trim().toUpperCase());
        }
        Page<Favorite> result = favoriteMapper.selectPage(new Page<>(PageQuery.clampPage(page), PageQuery.clampSize(size, 10)), wrapper);
        hydrateAll(result.getRecords());
        return PageResult.of(result);
    }

    private void ensureTarget(String type, Long id) {
        switch (type) {
            case "SPOT" -> {
                if (spotMapper.selectById(id) == null) {
                    throw new BizException("景点不存在");
                }
            }
            case "ROUTE" -> {
                if (routeMapper.selectById(id) == null) {
                    throw new BizException("路线不存在");
                }
            }
            case "NOTE" -> {
                TravelNote note = noteMapper.selectById(id);
                if (note == null) {
                    throw new BizException("游记不存在");
                }
            }
            default -> throw new BizException("收藏类型不正确");
        }
    }

    private void hydrateAll(List<Favorite> rows) {
        if (rows.isEmpty()) {
            return;
        }
        Map<String, List<Long>> ids = new HashMap<>();
        for (Favorite favorite : rows) {
            ids.computeIfAbsent(favorite.getTargetType(), key -> new ArrayList<>()).add(favorite.getTargetId());
        }
        Map<Long, ScenicSpot> spots = batch(ids.get("SPOT"), spotMapper::selectBatchIds);
        Map<Long, TourRoute> routes = batch(ids.get("ROUTE"), routeMapper::selectBatchIds);
        Map<Long, TravelNote> notes = batch(ids.get("NOTE"), noteMapper::selectBatchIds);
        for (Favorite favorite : rows) {
            switch (favorite.getTargetType()) {
                case "SPOT" -> {
                    ScenicSpot spot = spots.get(favorite.getTargetId());
                    boolean on = spot != null && Integer.valueOf(1).equals(spot.getStatus());
                    favorite.setAvailable(on);
                    favorite.setTitle(spot == null ? "景点已下架" : spot.getName());
                    favorite.setCoverUrl(on ? spot.getCoverUrl() : null);
                    favorite.setSubtitle(on ? spot.getProvince() + " · " + spot.getCity() : "已下架，不能继续查看");
                }
                case "ROUTE" -> {
                    TourRoute route = routes.get(favorite.getTargetId());
                    boolean on = route != null && Integer.valueOf(1).equals(route.getStatus());
                    favorite.setAvailable(on);
                    favorite.setTitle(route == null ? "路线已下线" : route.getTitle());
                    favorite.setCoverUrl(on ? route.getCoverUrl() : null);
                    favorite.setSubtitle(on ? route.getDays() + " 天行程" : "已下线，不能继续查看");
                }
                case "NOTE" -> {
                    TravelNote note = notes.get(favorite.getTargetId());
                    favorite.setAvailable(note != null);
                    favorite.setTitle(note == null ? "游记已删除" : note.getTitle());
                    favorite.setCoverUrl(note == null ? null : note.getCoverUrl());
                    favorite.setSubtitle(note == null ? "已删除，不能继续查看" : "游记");
                }
                default -> {
                    favorite.setAvailable(false);
                    favorite.setTitle("未知内容");
                    favorite.setSubtitle("不能继续查看");
                }
            }
        }
    }

    private <T> Map<Long, T> batch(List<Long> ids, Function<List<Long>, List<T>> loader) {
        if (ids == null || ids.isEmpty()) {
            return Map.of();
        }
        List<T> rows = loader.apply(ids);
        Map<Long, T> map = new HashMap<>();
        for (T row : rows) {
            Long id = idOf(row);
            if (id != null) {
                map.put(id, row);
            }
        }
        return map;
    }

    private Long idOf(Object row) {
        if (row instanceof ScenicSpot spot) return spot.getId();
        if (row instanceof TourRoute route) return route.getId();
        if (row instanceof TravelNote note) return note.getId();
        return null;
    }
}
