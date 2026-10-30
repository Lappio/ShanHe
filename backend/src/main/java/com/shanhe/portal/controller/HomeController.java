package com.shanhe.portal.controller;

import com.shanhe.portal.common.PageResult;
import com.shanhe.portal.common.R;
import com.shanhe.portal.entity.Banner;
import com.shanhe.portal.entity.News;
import com.shanhe.portal.entity.SpotCategory;
import com.shanhe.portal.service.ContentService;
import com.shanhe.portal.service.HomeService;
import com.shanhe.portal.vo.HomeVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class HomeController {
    private final HomeService homeService;
    private final ContentService contentService;

    @GetMapping("/home")
    public R<HomeVO> home() {
        return R.ok(homeService.load());
    }

    @GetMapping("/banners")
    public R<List<Banner>> banners() {
        return R.ok(contentService.banners(true));
    }

    @GetMapping("/categories")
    public R<List<SpotCategory>> categories() {
        return R.ok(contentService.categories());
    }

    @GetMapping("/news")
    public R<PageResult<News>> news(@RequestParam(defaultValue = "1") long page,
                                    @RequestParam(defaultValue = "8") long size) {
        return R.ok(contentService.pageNews(false, page, size));
    }

    @GetMapping("/news/{id}")
    public R<News> newsDetail(@PathVariable Long id) {
        return R.ok(contentService.newsDetail(id, false));
    }
}
