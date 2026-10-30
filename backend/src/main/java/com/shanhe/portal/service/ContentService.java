package com.shanhe.portal.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shanhe.portal.common.BizException;
import com.shanhe.portal.common.PageQuery;
import com.shanhe.portal.common.PageResult;
import com.shanhe.portal.dto.BannerSaveDTO;
import com.shanhe.portal.dto.CategorySaveDTO;
import com.shanhe.portal.dto.NewsSaveDTO;
import com.shanhe.portal.entity.Banner;
import com.shanhe.portal.entity.News;
import com.shanhe.portal.entity.ScenicSpot;
import com.shanhe.portal.entity.SpotCategory;
import com.shanhe.portal.mapper.BannerMapper;
import com.shanhe.portal.mapper.NewsMapper;
import com.shanhe.portal.mapper.ScenicSpotMapper;
import com.shanhe.portal.mapper.SpotCategoryMapper;
import com.shanhe.portal.security.HomeCache;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ContentService {
    private final SpotCategoryMapper categoryMapper;
    private final ScenicSpotMapper spotMapper;
    private final BannerMapper bannerMapper;
    private final NewsMapper newsMapper;
    private final HomeCache homeCache;

    public List<SpotCategory> categories() {
        return categoryMapper.selectList(new LambdaQueryWrapper<SpotCategory>().orderByAsc(SpotCategory::getSortOrder).orderByAsc(SpotCategory::getId));
    }

    public Long saveCategory(CategorySaveDTO dto) {
        SpotCategory category = dto.getId() == null ? new SpotCategory() : categoryMapper.selectById(dto.getId());
        if (category == null) {
            throw new BizException("分类不存在");
        }
        category.setName(dto.getName().trim());
        category.setDescription(dto.getDescription());
        category.setIcon(StringUtils.hasText(dto.getIcon()) ? dto.getIcon().trim() : null);
        category.setSortOrder(dto.getSortOrder() == null ? 0 : dto.getSortOrder());
        if (dto.getId() == null) {
            categoryMapper.insert(category);
        } else {
            categoryMapper.updateById(category);
        }
        homeCache.evict();
        return category.getId();
    }

    public void deleteCategory(Long id) {
        if (spotMapper.selectCount(new LambdaQueryWrapper<ScenicSpot>().eq(ScenicSpot::getCategoryId, id)) > 0) {
            throw new BizException("该分类下仍有景点，不能删除");
        }
        categoryMapper.deleteById(id);
        homeCache.evict();
    }

    public List<Banner> banners(boolean onlyEnabled) {
        LambdaQueryWrapper<Banner> wrapper = new LambdaQueryWrapper<Banner>().orderByAsc(Banner::getSortOrder).orderByAsc(Banner::getId);
        if (onlyEnabled) {
            wrapper.eq(Banner::getStatus, 1);
        }
        return bannerMapper.selectList(wrapper);
    }

    public Long saveBanner(BannerSaveDTO dto) {
        Banner banner = dto.getId() == null ? new Banner() : bannerMapper.selectById(dto.getId());
        if (banner == null) {
            throw new BizException("轮播不存在");
        }
        banner.setTitle(dto.getTitle().trim());
        banner.setSubtitle(dto.getSubtitle());
        banner.setImageUrl(dto.getImageUrl().trim());
        banner.setLinkUrl(StringUtils.hasText(dto.getLinkUrl()) ? dto.getLinkUrl().trim() : null);
        banner.setSortOrder(dto.getSortOrder() == null ? 0 : dto.getSortOrder());
        banner.setStatus(dto.getStatus() != null && dto.getStatus() == 0 ? 0 : 1);
        if (dto.getId() == null) {
            bannerMapper.insert(banner);
        } else {
            bannerMapper.updateById(banner);
        }
        homeCache.evict();
        return banner.getId();
    }

    public void deleteBanner(Long id) {
        bannerMapper.deleteById(id);
        homeCache.evict();
    }

    public PageResult<News> pageNews(boolean admin, long page, long size) {
        LambdaQueryWrapper<News> wrapper = new LambdaQueryWrapper<News>().orderByDesc(News::getPublishedAt);
        if (!admin) {
            wrapper.eq(News::getStatus, 1);
        }
        Page<News> result = newsMapper.selectPage(new Page<>(PageQuery.clampPage(page), PageQuery.clampSize(size, 10)), wrapper);
        if (!admin) {
            result.getRecords().forEach(item -> item.setContent(null));
        }
        return PageResult.of(result);
    }

    public List<News> latest(int limit) {
        List<News> list = newsMapper.selectList(new LambdaQueryWrapper<News>()
                .eq(News::getStatus, 1)
                .orderByDesc(News::getPublishedAt)
                .last("LIMIT " + Math.min(limit, 8)));
        list.forEach(item -> item.setContent(null));
        return list;
    }

    public News newsDetail(Long id, boolean admin) {
        News news = newsMapper.selectById(id);
        if (news == null || (!admin && (news.getStatus() == null || news.getStatus() != 1))) {
            throw new BizException("资讯不存在");
        }
        return news;
    }

    public Long saveNews(NewsSaveDTO dto) {
        News news = dto.getId() == null ? new News() : newsMapper.selectById(dto.getId());
        if (news == null) {
            throw new BizException("资讯不存在");
        }
        news.setTitle(dto.getTitle().trim());
        news.setCoverUrl(StringUtils.hasText(dto.getCoverUrl()) ? dto.getCoverUrl().trim() : null);
        news.setSummary(dto.getSummary().trim());
        news.setContent(dto.getContent().trim());
        news.setStatus(dto.getStatus() != null && dto.getStatus() == 0 ? 0 : 1);
        news.setPublishedAt(dto.getPublishedAt() == null ? LocalDateTime.now() : dto.getPublishedAt());
        if (dto.getId() == null) {
            newsMapper.insert(news);
        } else {
            newsMapper.updateById(news);
        }
        homeCache.evict();
        return news.getId();
    }

    public void deleteNews(Long id) {
        newsMapper.deleteById(id);
        homeCache.evict();
    }
}
