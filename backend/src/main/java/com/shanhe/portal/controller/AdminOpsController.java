package com.shanhe.portal.controller;

import com.shanhe.portal.common.PageResult;
import com.shanhe.portal.common.R;
import com.shanhe.portal.dto.AuditDTO;
import com.shanhe.portal.dto.StatusDTO;
import com.shanhe.portal.dto.UserUpdateDTO;
import com.shanhe.portal.entity.BookingOrder;
import com.shanhe.portal.entity.Comment;
import com.shanhe.portal.entity.TravelNote;
import com.shanhe.portal.entity.User;
import com.shanhe.portal.service.AuthService;
import com.shanhe.portal.service.CommentService;
import com.shanhe.portal.service.NoteService;
import com.shanhe.portal.service.OrderService;
import com.shanhe.portal.service.StatsService;
import com.shanhe.portal.vo.StatsVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminOpsController {
    private final OrderService orderService;
    private final NoteService noteService;
    private final CommentService commentService;
    private final AuthService authService;
    private final StatsService statsService;

    @GetMapping("/stats")
    public R<StatsVO> stats() {
        return R.ok(statsService.load());
    }

    @GetMapping("/orders")
    public R<PageResult<BookingOrder>> orders(@RequestParam(required = false) String status,
                                              @RequestParam(required = false) String keyword,
                                              @RequestParam(defaultValue = "1") long page,
                                              @RequestParam(defaultValue = "10") long size) {
        return R.ok(orderService.adminPage(status, keyword, page, size));
    }

    @PutMapping("/orders/{id}/status")
    public R<Void> orderStatus(@PathVariable Long id, @Valid @RequestBody StatusDTO dto) {
        orderService.adminStatus(id, dto.getStatus());
        return R.ok();
    }

    @GetMapping("/notes")
    public R<PageResult<TravelNote>> notes(@RequestParam(required = false) String status,
                                           @RequestParam(required = false) String keyword,
                                           @RequestParam(defaultValue = "1") long page,
                                           @RequestParam(defaultValue = "10") long size) {
        return R.ok(noteService.page(keyword, status, null, page, size, false));
    }

    @PutMapping("/notes/{id}/audit")
    public R<Void> audit(@PathVariable Long id, @Valid @RequestBody AuditDTO dto) {
        noteService.audit(id, dto);
        return R.ok();
    }

    @DeleteMapping("/notes/{id}")
    public R<Void> deleteNote(@PathVariable Long id) {
        noteService.delete(id);
        return R.ok();
    }

    @GetMapping("/comments")
    public R<PageResult<Comment>> comments(@RequestParam(required = false) String status,
                                           @RequestParam(required = false) String keyword,
                                           @RequestParam(defaultValue = "1") long page,
                                           @RequestParam(defaultValue = "10") long size) {
        return R.ok(commentService.page(null, null, status, keyword, true, page, size));
    }

    @PutMapping("/comments/{id}/status")
    public R<Void> commentStatus(@PathVariable Long id, @Valid @RequestBody StatusDTO dto) {
        commentService.updateStatus(id, dto.getStatus());
        return R.ok();
    }

    @DeleteMapping("/comments/{id}")
    public R<Void> deleteComment(@PathVariable Long id) {
        commentService.delete(id);
        return R.ok();
    }

    @GetMapping("/users")
    public R<PageResult<User>> users(@RequestParam(required = false) String keyword,
                                     @RequestParam(defaultValue = "1") long page,
                                     @RequestParam(defaultValue = "10") long size) {
        return R.ok(authService.page(keyword, page, size));
    }

    @PutMapping("/users/{id}")
    public R<Void> updateUser(@PathVariable Long id, @Valid @RequestBody UserUpdateDTO dto) {
        authService.adminUpdate(id, dto);
        return R.ok();
    }
}
