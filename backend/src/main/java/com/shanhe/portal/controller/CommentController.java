package com.shanhe.portal.controller;

import com.shanhe.portal.common.PageResult;
import com.shanhe.portal.common.R;
import com.shanhe.portal.dto.CommentCreateDTO;
import com.shanhe.portal.entity.Comment;
import com.shanhe.portal.service.CommentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/comments")
@RequiredArgsConstructor
public class CommentController {
    private final CommentService commentService;

    @GetMapping
    public R<PageResult<Comment>> page(@RequestParam String targetType,
                                       @RequestParam Long targetId,
                                       @RequestParam(defaultValue = "1") long page,
                                       @RequestParam(defaultValue = "8") long size) {
        return R.ok(commentService.page(targetType, targetId, null, null, false, page, size));
    }

    @PostMapping
    public R<Long> create(@Valid @RequestBody CommentCreateDTO dto) {
        return R.ok(commentService.create(dto));
    }

    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable Long id) {
        commentService.delete(id);
        return R.ok();
    }
}
