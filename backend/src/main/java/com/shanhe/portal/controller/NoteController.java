package com.shanhe.portal.controller;

import com.shanhe.portal.common.PageResult;
import com.shanhe.portal.common.R;
import com.shanhe.portal.common.UserContext;
import com.shanhe.portal.dto.NoteSaveDTO;
import com.shanhe.portal.entity.TravelNote;
import com.shanhe.portal.service.NoteService;
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

import java.util.Map;

@RestController
@RequestMapping("/api/notes")
@RequiredArgsConstructor
public class NoteController {
    private final NoteService noteService;

    @GetMapping
    public R<PageResult<TravelNote>> page(@RequestParam(required = false) String keyword,
                                          @RequestParam(defaultValue = "1") long page,
                                          @RequestParam(defaultValue = "8") long size) {
        return R.ok(noteService.page(keyword, "APPROVED", null, page, size, false));
    }

    @GetMapping("/mine")
    public R<PageResult<TravelNote>> mine(@RequestParam(defaultValue = "1") long page,
                                          @RequestParam(defaultValue = "8") long size) {
        return R.ok(noteService.page(null, null, UserContext.require().getId(), page, size, false));
    }

    @GetMapping("/{id}")
    public R<TravelNote> detail(@PathVariable Long id) {
        return R.ok(noteService.detail(id));
    }

    @PostMapping
    public R<Long> create(@Valid @RequestBody NoteSaveDTO dto) {
        return R.ok(noteService.create(dto));
    }

    @PutMapping("/{id}")
    public R<Void> update(@PathVariable Long id, @Valid @RequestBody NoteSaveDTO dto) {
        noteService.update(id, dto);
        return R.ok();
    }

    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable Long id) {
        noteService.delete(id);
        return R.ok();
    }

    @PostMapping("/{id}/like")
    public R<Map<String, Boolean>> like(@PathVariable Long id) {
        return R.ok(Map.of("liked", noteService.toggleLike(id)));
    }
}
