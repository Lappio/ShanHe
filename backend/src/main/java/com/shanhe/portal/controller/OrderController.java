package com.shanhe.portal.controller;

import com.shanhe.portal.common.PageResult;
import com.shanhe.portal.common.R;
import com.shanhe.portal.dto.OrderCreateDTO;
import com.shanhe.portal.entity.BookingOrder;
import com.shanhe.portal.service.OrderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {
    private final OrderService orderService;

    @PostMapping
    public R<BookingOrder> create(@Valid @RequestBody OrderCreateDTO dto) {
        return R.ok(orderService.create(dto));
    }

    @GetMapping("/mine")
    public R<PageResult<BookingOrder>> mine(@RequestParam(required = false) String status,
                                            @RequestParam(defaultValue = "1") long page,
                                            @RequestParam(defaultValue = "8") long size) {
        return R.ok(orderService.mine(status, page, size));
    }

    @PutMapping("/{id}/cancel")
    public R<Void> cancel(@PathVariable Long id) {
        orderService.cancel(id);
        return R.ok();
    }
}
