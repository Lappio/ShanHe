package com.shanhe.portal.controller;

import com.shanhe.portal.common.PageResult;
import com.shanhe.portal.common.R;
import com.shanhe.portal.dto.FavoriteDTO;
import com.shanhe.portal.entity.Favorite;
import com.shanhe.portal.service.FavoriteService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/favorites")
@RequiredArgsConstructor
public class FavoriteController {
    private final FavoriteService favoriteService;

    @PostMapping("/toggle")
    public R<Map<String, Boolean>> toggle(@Valid @RequestBody FavoriteDTO dto) {
        return R.ok(Map.of("favorited", favoriteService.toggle(dto)));
    }

    @GetMapping("/mine")
    public R<PageResult<Favorite>> mine(@RequestParam(required = false) String targetType,
                                        @RequestParam(defaultValue = "1") long page,
                                        @RequestParam(defaultValue = "12") long size) {
        return R.ok(favoriteService.mine(targetType, page, size));
    }
}
