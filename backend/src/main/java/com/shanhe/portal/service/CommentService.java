package com.shanhe.portal.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shanhe.portal.common.BizException;
import com.shanhe.portal.common.LoginUser;
import com.shanhe.portal.common.PageResult;
import com.shanhe.portal.common.UserContext;
import com.shanhe.portal.dto.CommentCreateDTO;
import com.shanhe.portal.entity.Comment;
import com.shanhe.portal.entity.ScenicSpot;
import com.shanhe.portal.entity.TravelNote;
import com.shanhe.portal.entity.User;
import com.shanhe.portal.mapper.CommentMapper;
import com.shanhe.portal.mapper.ScenicSpotMapper;
import com.shanhe.portal.mapper.TravelNoteMapper;
import com.shanhe.portal.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CommentService {
    private final CommentMapper commentMapper;
    private final UserMapper userMapper;
    private final ScenicSpotMapper spotMapper;
    private final TravelNoteMapper noteMapper;

    public PageResult<Comment> page(String targetType, Long targetId, String status, String keyword, boolean admin, long page, long size) {
        LambdaQueryWrapper<Comment> wrapper = new LambdaQueryWrapper<Comment>().orderByDesc(Comment::getCreatedAt);
        if (StringUtils.hasText(targetType)) {
            wrapper.eq(Comment::getTargetType, targetType.trim());
        }
        if (targetId != null) {
            wrapper.eq(Comment::getTargetId, targetId);
        }
        if (!admin) {
            wrapper.eq(Comment::getStatus, "VISIBLE");
        } else if (StringUtils.hasText(status)) {
            wrapper.eq(Comment::getStatus, status.trim());
        }
        if (StringUtils.hasText(keyword)) {
            wrapper.like(Comment::getContent, keyword.trim());
        }
        Page<Comment> result = commentMapper.selectPage(new Page<>(Math.max(page, 1), Math.min(Math.max(size, 1), 50)), wrapper);
        fill(result.getRecords());
        return PageResult.of(result);
    }

    public Long create(CommentCreateDTO dto) {
        String type = dto.getTargetType().trim().toUpperCase();
        if (!"SPOT".equals(type) && !"NOTE".equals(type)) {
            throw new BizException("评论目标不正确");
        }
        if ("SPOT".equals(type)) {
            ScenicSpot spot = spotMapper.selectById(dto.getTargetId());
            if (spot == null || spot.getStatus() == null || spot.getStatus() != 1) {
                throw new BizException("景点不存在");
            }
        } else {
            TravelNote note = noteMapper.selectById(dto.getTargetId());
            if (note == null || !"APPROVED".equals(note.getStatus())) {
                throw new BizException("游记未公开，暂不能评论");
            }
        }
        Comment comment = new Comment();
        comment.setUserId(UserContext.require().getId());
        comment.setTargetType(type);
        comment.setTargetId(dto.getTargetId());
        comment.setContent(dto.getContent().trim());
        comment.setStatus("VISIBLE");
        commentMapper.insert(comment);
        return comment.getId();
    }

    public void delete(Long id) {
        Comment comment = commentMapper.selectById(id);
        if (comment == null) {
            throw new BizException("评论不存在");
        }
        LoginUser user = UserContext.require();
        if (!user.getId().equals(comment.getUserId()) && !"ADMIN".equals(user.getRole())) {
            throw new BizException(403, "只能删除自己的评论");
        }
        commentMapper.deleteById(id);
    }

    public void updateStatus(Long id, String status) {
        if (!"VISIBLE".equals(status) && !"HIDDEN".equals(status)) {
            throw new BizException("评论状态不正确");
        }
        Comment comment = commentMapper.selectById(id);
        if (comment == null) {
            throw new BizException("评论不存在");
        }
        comment.setStatus(status);
        commentMapper.updateById(comment);
    }

    private void fill(List<Comment> comments) {
        if (comments.isEmpty()) {
            return;
        }
        Map<Long, User> users = userMapper.selectBatchIds(comments.stream().map(Comment::getUserId).collect(Collectors.toSet()))
                .stream().collect(Collectors.toMap(User::getId, user -> user));
        comments.forEach(comment -> {
            User user = users.get(comment.getUserId());
            if (user != null) {
                comment.setNickname(user.getNickname());
                comment.setAvatar(user.getAvatar());
            }
        });
    }
}
