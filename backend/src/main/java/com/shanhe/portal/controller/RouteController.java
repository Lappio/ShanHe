package com.shanhe.portal.controller;

import com.shanhe.portal.common.PageResult;
import com.shanhe.portal.common.R;
import com.shanhe.portal.entity.TourRoute;
import com.shanhe.portal.service.RouteService;
import com.shanhe.portal.vo.RouteDetailVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/routes")
@RequiredArgsConstructor
public class RouteController {
    private final RouteService routeService;

    @GetMapping
    public R<PageResult<TourRoute>> page(@RequestParam(required = false) String keyword,
                                         @RequestParam(defaultValue = "1") long page,
                                         @RequestParam(defaultValue = "8") long size) {
        return R.ok(routeService.page(keyword, false, page, size));
    }

    @GetMapping("/{id}")
    public R<RouteDetailVO> detail(@PathVariable Long id) {
        return R.ok(routeService.detail(id, false));
    }
}
