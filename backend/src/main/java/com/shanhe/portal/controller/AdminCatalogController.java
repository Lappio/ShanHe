package com.shanhe.portal.controller;

import com.shanhe.portal.common.PageResult;
import com.shanhe.portal.common.R;
import com.shanhe.portal.dto.CategorySaveDTO;
import com.shanhe.portal.dto.SpotQuery;
import com.shanhe.portal.dto.SpotSaveDTO;
import com.shanhe.portal.dto.TicketSaveDTO;
import com.shanhe.portal.entity.ScenicSpot;
import com.shanhe.portal.entity.SpotCategory;
import com.shanhe.portal.entity.TicketType;
import com.shanhe.portal.service.ContentService;
import com.shanhe.portal.service.SpotService;
import com.shanhe.portal.vo.SpotDetailVO;
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
public class AdminCatalogController {
    private final SpotService spotService;
    private final ContentService contentService;

    @GetMapping("/categories")
    public R<List<SpotCategory>> categories() {
        return R.ok(contentService.categories());
    }

    @PostMapping("/categories")
    public R<Long> createCategory(@Valid @RequestBody CategorySaveDTO dto) {
        dto.setId(null);
        return R.ok(contentService.saveCategory(dto));
    }

    @PutMapping("/categories/{id}")
    public R<Long> updateCategory(@PathVariable Long id, @Valid @RequestBody CategorySaveDTO dto) {
        dto.setId(id);
        return R.ok(contentService.saveCategory(dto));
    }

    @DeleteMapping("/categories/{id}")
    public R<Void> deleteCategory(@PathVariable Long id) {
        contentService.deleteCategory(id);
        return R.ok();
    }

    @GetMapping("/spots")
    public R<PageResult<ScenicSpot>> spots(SpotQuery query) {
        return R.ok(spotService.page(query, true));
    }

    @GetMapping("/spots/options")
    public R<List<ScenicSpot>> options() {
        return R.ok(spotService.options());
    }

    @GetMapping("/spots/{id}")
    public R<SpotDetailVO> spot(@PathVariable Long id) {
        return R.ok(spotService.detail(id, true));
    }

    @PostMapping("/spots")
    public R<Long> createSpot(@Valid @RequestBody SpotSaveDTO dto) {
        dto.setId(null);
        return R.ok(spotService.save(dto));
    }

    @PutMapping("/spots/{id}")
    public R<Long> updateSpot(@PathVariable Long id, @Valid @RequestBody SpotSaveDTO dto) {
        dto.setId(id);
        return R.ok(spotService.save(dto));
    }

    @DeleteMapping("/spots/{id}")
    public R<Void> deleteSpot(@PathVariable Long id) {
        spotService.delete(id);
        return R.ok();
    }

    @GetMapping("/tickets")
    public R<PageResult<TicketType>> tickets(@RequestParam(required = false) Long spotId,
                                             @RequestParam(defaultValue = "1") long page,
                                             @RequestParam(defaultValue = "10") long size) {
        return R.ok(spotService.tickets(spotId, page, size));
    }

    @PostMapping("/tickets")
    public R<Long> createTicket(@Valid @RequestBody TicketSaveDTO dto) {
        dto.setId(null);
        return R.ok(spotService.saveTicket(dto));
    }

    @PutMapping("/tickets/{id}")
    public R<Long> updateTicket(@PathVariable Long id, @Valid @RequestBody TicketSaveDTO dto) {
        dto.setId(id);
        return R.ok(spotService.saveTicket(dto));
    }

    @DeleteMapping("/tickets/{id}")
    public R<Void> deleteTicket(@PathVariable Long id) {
        spotService.deleteTicket(id);
        return R.ok();
    }
}
