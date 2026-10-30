package com.shanhe.portal.controller;

import com.shanhe.portal.common.PageResult;
import com.shanhe.portal.common.R;
import com.shanhe.portal.dto.SpotQuery;
import com.shanhe.portal.entity.ScenicSpot;
import com.shanhe.portal.service.SpotService;
import com.shanhe.portal.vo.SpotDetailVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/spots")
@RequiredArgsConstructor
public class SpotController {
    private final SpotService spotService;

    @GetMapping
    public R<PageResult<ScenicSpot>> page(SpotQuery query) {
        return R.ok(spotService.page(query, false));
    }

    @GetMapping("/hot")
    public R<List<ScenicSpot>> hot(@RequestParam(defaultValue = "8") int limit) {
        return R.ok(spotService.hot(limit));
    }

    @GetMapping("/provinces")
    public R<List<String>> provinces() {
        return R.ok(spotService.provinces());
    }

    @GetMapping("/{id}")
    public R<SpotDetailVO> detail(@PathVariable Long id) {
        return R.ok(spotService.detail(id, false));
    }
}
