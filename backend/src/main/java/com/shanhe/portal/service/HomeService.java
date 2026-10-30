package com.shanhe.portal.service;

import com.shanhe.portal.vo.HomeVO;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class HomeService {
    private final ContentService contentService;
    private final SpotService spotService;
    private final RouteService routeService;
    private final NoteService noteService;

    @Cacheable("home")
    public HomeVO load() {
        HomeVO vo = new HomeVO();
        vo.setBanners(contentService.banners(true));
        vo.setCategories(contentService.categories());
        vo.setHotSpots(spotService.hot(8));
        vo.setRoutes(routeService.recommend(6));
        vo.setNews(contentService.latest(4));
        vo.setNotes(noteService.latest(4));
        return vo;
    }
}
