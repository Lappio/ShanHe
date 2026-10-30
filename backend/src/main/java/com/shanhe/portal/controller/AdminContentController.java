package com.shanhe.portal.controller;

import com.shanhe.portal.common.PageResult;
import com.shanhe.portal.common.R;
import com.shanhe.portal.dto.BannerSaveDTO;
import com.shanhe.portal.dto.NewsSaveDTO;
import com.shanhe.portal.dto.RouteSaveDTO;
import com.shanhe.portal.entity.Banner;
import com.shanhe.portal.entity.News;
import com.shanhe.portal.entity.TourRoute;
import com.shanhe.portal.service.ContentService;
import com.shanhe.portal.service.RouteService;
import com.shanhe.portal.vo.RouteDetailVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminContentController {
    private final RouteService routeService;
    private final ContentService contentService;

    @GetMapping("/routes")
    public R<PageResult<TourRoute>> routes(@RequestParam(required = false) String keyword,
                                           @RequestParam(defaultValue = "1") long page,
                                           @RequestParam(defaultValue = "10") long size) {
        return R.ok(routeService.page(keyword, true, page, size));
    }

    @GetMapping("/routes/{id}")
    public R<RouteDetailVO> route(@PathVariable Long id) {
        return R.ok(routeService.detail(id, true));
    }

    @PostMapping("/routes")
    public R<Long> createRoute(@Valid @RequestBody RouteSaveDTO dto) {
        dto.setId(null);
        return R.ok(routeService.save(dto));
    }

    @PutMapping("/routes/{id}")
    public R<Long> updateRoute(@PathVariable Long id, @Valid @RequestBody RouteSaveDTO dto) {
        dto.setId(id);
        return R.ok(routeService.save(dto));
    }

    @DeleteMapping("/routes/{id}")
    public R<Void> deleteRoute(@PathVariable Long id) {
        routeService.delete(id);
        return R.ok();
    }

    @GetMapping("/banners")
    public R<List<Banner>> banners() {
        return R.ok(contentService.banners(false));
    }

    @PostMapping("/banners")
    public R<Long> createBanner(@Valid @RequestBody BannerSaveDTO dto) {
        dto.setId(null);
        return R.ok(contentService.saveBanner(dto));
    }

    @PutMapping("/banners/{id}")
    public R<Long> updateBanner(@PathVariable Long id, @Valid @RequestBody BannerSaveDTO dto) {
        dto.setId(id);
        return R.ok(contentService.saveBanner(dto));
    }

    @DeleteMapping("/banners/{id}")
    public R<Void> deleteBanner(@PathVariable Long id) {
        contentService.deleteBanner(id);
        return R.ok();
    }

    @GetMapping("/news")
    public R<PageResult<News>> news(@RequestParam(defaultValue = "1") long page,
                                    @RequestParam(defaultValue = "10") long size) {
        return R.ok(contentService.pageNews(true, page, size));
    }

    @GetMapping("/news/{id}")
    public R<News> newsDetail(@PathVariable Long id) {
        return R.ok(contentService.newsDetail(id, true));
    }

    @PostMapping("/news")
    public R<Long> createNews(@Valid @RequestBody NewsSaveDTO dto) {
        dto.setId(null);
        return R.ok(contentService.saveNews(dto));
    }

    @PutMapping("/news/{id}")
    public R<Long> updateNews(@PathVariable Long id, @Valid @RequestBody NewsSaveDTO dto) {
        dto.setId(id);
        return R.ok(contentService.saveNews(dto));
    }

    @DeleteMapping("/news/{id}")
    public R<Void> deleteNews(@PathVariable Long id) {
        contentService.deleteNews(id);
        return R.ok();
    }
}
