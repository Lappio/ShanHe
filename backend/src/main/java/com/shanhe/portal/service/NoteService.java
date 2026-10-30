package com.shanhe.portal.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shanhe.portal.common.BizException;
import com.shanhe.portal.common.LoginUser;
import com.shanhe.portal.common.PageResult;
import com.shanhe.portal.common.UserContext;
import com.shanhe.portal.dto.AuditDTO;
import com.shanhe.portal.dto.NoteSaveDTO;
import com.shanhe.portal.entity.Comment;
import com.shanhe.portal.entity.Favorite;
import com.shanhe.portal.entity.NoteLike;
import com.shanhe.portal.entity.ScenicSpot;
import com.shanhe.portal.entity.TravelNote;
import com.shanhe.portal.entity.User;
import com.shanhe.portal.mapper.CommentMapper;
import com.shanhe.portal.mapper.FavoriteMapper;
import com.shanhe.portal.mapper.NoteLikeMapper;
import com.shanhe.portal.mapper.ScenicSpotMapper;
import com.shanhe.portal.mapper.TravelNoteMapper;
import com.shanhe.portal.mapper.UserMapper;
import com.shanhe.portal.security.HomeCache;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NoteService {
    private final TravelNoteMapper noteMapper;
    private final NoteLikeMapper likeMapper;
    private final UserMapper userMapper;
    private final ScenicSpotMapper spotMapper;
    private final CommentMapper commentMapper;
    private final FavoriteMapper favoriteMapper;
    private final HomeCache homeCache;

    public PageResult<TravelNote> page(String keyword, String status, Long userId, long page, long size, boolean keepContent) {
        LambdaQueryWrapper<TravelNote> wrapper = new LambdaQueryWrapper<>();
        if (userId != null) {
            wrapper.eq(TravelNote::getUserId, userId);
        }
        if (StringUtils.hasText(status)) {
            wrapper.eq(TravelNote::getStatus, status.trim());
        }
        if (StringUtils.hasText(keyword)) {
            wrapper.like(TravelNote::getTitle, keyword.trim());
        }
        wrapper.orderByDesc(TravelNote::getCreatedAt);
        Page<TravelNote> result = noteMapper.selectPage(new Page<>(Math.max(page, 1), Math.min(Math.max(size, 1), 50)), wrapper);
        fill(result.getRecords(), keepContent);
        return PageResult.of(result);
    }

    public List<TravelNote> latest(int limit) {
        List<TravelNote> list = noteMapper.selectList(new LambdaQueryWrapper<TravelNote>()
                .eq(TravelNote::getStatus, "APPROVED")
                .orderByDesc(TravelNote::getCreatedAt)
                .last("LIMIT " + Math.min(limit, 8)));
        fill(list, false);
        return list;
    }

    public TravelNote detail(Long id) {
        TravelNote note = noteMapper.selectById(id);
        if (note == null) {
            throw new BizException("游记不存在");
        }
        LoginUser user = UserContext.get();
        boolean owner = user != null && user.getId().equals(note.getUserId());
        boolean admin = user != null && "ADMIN".equals(user.getRole());
        if (!"APPROVED".equals(note.getStatus()) && !owner && !admin) {
            throw new BizException("游记不存在或尚未通过审核");
        }
        if ("APPROVED".equals(note.getStatus())) {
            noteMapper.update(null, new LambdaUpdateWrapper<TravelNote>()
                    .eq(TravelNote::getId, id)
                    .setSql("view_count = view_count + 1"));
            note.setViewCount((note.getViewCount() == null ? 0 : note.getViewCount()) + 1);
        }
        fill(List.of(note), true);
        if (user != null) {
            Long likes = likeMapper.selectCount(new LambdaQueryWrapper<NoteLike>()
                    .eq(NoteLike::getNoteId, id).eq(NoteLike::getUserId, user.getId()));
            note.setLiked(likes != null && likes > 0);
            Long fav = favoriteMapper.selectCount(new LambdaQueryWrapper<Favorite>()
                    .eq(Favorite::getUserId, user.getId())
                    .eq(Favorite::getTargetType, "NOTE")
                    .eq(Favorite::getTargetId, id));
            note.setFavorited(fav != null && fav > 0);
        } else {
            note.setLiked(false);
            note.setFavorited(false);
        }
        return note;
    }

    @Transactional
    public Long create(NoteSaveDTO dto) {
        TravelNote note = new TravelNote();
        note.setUserId(UserContext.require().getId());
        apply(note, dto);
        note.setStatus("PENDING");
        note.setLikeCount(0);
        note.setViewCount(0);
        noteMapper.insert(note);
        return note.getId();
    }

    @Transactional
    public void update(Long id, NoteSaveDTO dto) {
        TravelNote note = own(id);
        apply(note, dto);
        noteMapper.update(null, new LambdaUpdateWrapper<TravelNote>()
                .eq(TravelNote::getId, id)
                .set(TravelNote::getTitle, note.getTitle())
                .set(TravelNote::getContent, note.getContent())
                .set(TravelNote::getCoverUrl, note.getCoverUrl())
                .set(TravelNote::getSpotId, note.getSpotId())
                .set(TravelNote::getStatus, "PENDING")
                .set(TravelNote::getRejectReason, null));
        homeCache.evict();
    }

    @Transactional
    public void delete(Long id) {
        TravelNote note = noteMapper.selectById(id);
        if (note == null) {
            throw new BizException("游记不存在");
        }
        LoginUser user = UserContext.require();
        if (!user.getId().equals(note.getUserId()) && !"ADMIN".equals(user.getRole())) {
            throw new BizException(403, "只能删除自己的游记");
        }
        commentMapper.delete(new LambdaQueryWrapper<Comment>().eq(Comment::getTargetType, "NOTE").eq(Comment::getTargetId, id));
        favoriteMapper.delete(new LambdaQueryWrapper<Favorite>().eq(Favorite::getTargetType, "NOTE").eq(Favorite::getTargetId, id));
        noteMapper.deleteById(id);
        homeCache.evict();
    }

    @Transactional
    public boolean toggleLike(Long id) {
        TravelNote note = noteMapper.selectById(id);
        if (note == null || !"APPROVED".equals(note.getStatus())) {
            throw new BizException("只能为已通过的游记点赞");
        }
        Long userId = UserContext.require().getId();
        NoteLike existing = likeMapper.selectOne(new LambdaQueryWrapper<NoteLike>()
                .eq(NoteLike::getNoteId, id).eq(NoteLike::getUserId, userId));
        if (existing != null) {
            likeMapper.deleteById(existing.getId());
            noteMapper.update(null, new LambdaUpdateWrapper<TravelNote>()
                    .eq(TravelNote::getId, id)
                    .setSql("like_count = GREATEST(like_count - 1, 0)"));
            return false;
        }
        NoteLike like = new NoteLike();
        like.setNoteId(id);
        like.setUserId(userId);
        likeMapper.insert(like);
        noteMapper.update(null, new LambdaUpdateWrapper<TravelNote>()
                .eq(TravelNote::getId, id)
                .setSql("like_count = like_count + 1"));
        return true;
    }

    public void audit(Long id, AuditDTO dto) {
        if (!"APPROVED".equals(dto.getStatus()) && !"REJECTED".equals(dto.getStatus())) {
            throw new BizException("审核状态不正确");
        }
        if ("REJECTED".equals(dto.getStatus()) && !StringUtils.hasText(dto.getRejectReason())) {
            throw new BizException("请填写驳回原因");
        }
        if (noteMapper.selectById(id) == null) {
            throw new BizException("游记不存在");
        }
        noteMapper.update(null, new LambdaUpdateWrapper<TravelNote>()
                .eq(TravelNote::getId, id)
                .set(TravelNote::getStatus, dto.getStatus())
                .set(TravelNote::getRejectReason, "REJECTED".equals(dto.getStatus()) ? dto.getRejectReason().trim() : null));
        homeCache.evict();
    }

    private TravelNote own(Long id) {
        TravelNote note = noteMapper.selectById(id);
        if (note == null) {
            throw new BizException("游记不存在");
        }
        if (!note.getUserId().equals(UserContext.require().getId())) {
            throw new BizException(403, "只能编辑自己的游记");
        }
        return note;
    }

    private void apply(TravelNote note, NoteSaveDTO dto) {
        note.setTitle(dto.getTitle().trim());
        note.setContent(dto.getContent().trim());
        note.setSpotId(dto.getSpotId());
        if (dto.getSpotId() != null && spotMapper.selectById(dto.getSpotId()) == null) {
            throw new BizException("关联景点不存在");
        }
        if (StringUtils.hasText(dto.getCoverUrl())) {
            note.setCoverUrl(dto.getCoverUrl().trim());
        } else if (dto.getSpotId() != null) {
            ScenicSpot spot = spotMapper.selectById(dto.getSpotId());
            note.setCoverUrl(spot == null ? null : spot.getCoverUrl());
        } else {
            note.setCoverUrl(null);
        }
    }

    private void fill(List<TravelNote> notes, boolean keepContent) {
        if (notes.isEmpty()) {
            return;
        }
        Set<Long> userIds = notes.stream().map(TravelNote::getUserId).collect(Collectors.toSet());
        Set<Long> spotIds = notes.stream().map(TravelNote::getSpotId).filter(Objects::nonNull).collect(Collectors.toSet());
        Map<Long, User> users = userMapper.selectBatchIds(userIds).stream().collect(Collectors.toMap(User::getId, user -> user));
        Map<Long, ScenicSpot> spots = new java.util.HashMap<>();
        if (!spotIds.isEmpty()) {
            spotMapper.selectBatchIds(spotIds).forEach(spot -> spots.put(spot.getId(), spot));
        }
        for (TravelNote note : notes) {
            User user = users.get(note.getUserId());
            if (user != null) {
                note.setAuthorName(user.getNickname());
                note.setAuthorAvatar(user.getAvatar());
            }
            ScenicSpot spot = note.getSpotId() == null ? null : spots.get(note.getSpotId());
            if (spot != null) {
                note.setSpotName(spot.getName());
            }
            if (note.getContent() != null) {
                String plain = note.getContent().replace('\n', ' ').trim();
                note.setExcerpt(plain.length() > 96 ? plain.substring(0, 96) + "…" : plain);
                if (!keepContent) {
                    note.setContent(null);
                }
            }
        }
    }
}
