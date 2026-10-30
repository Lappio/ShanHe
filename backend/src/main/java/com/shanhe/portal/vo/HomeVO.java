package com.shanhe.portal.vo;

import com.shanhe.portal.entity.Banner;
import com.shanhe.portal.entity.News;
import com.shanhe.portal.entity.ScenicSpot;
import com.shanhe.portal.entity.SpotCategory;
import com.shanhe.portal.entity.TourRoute;
import com.shanhe.portal.entity.TravelNote;
import lombok.Data;

import java.util.List;

@Data
public class HomeVO {
    private List<Banner> banners;
    private List<SpotCategory> categories;
    private List<ScenicSpot> hotSpots;
    private List<TourRoute> routes;
    private List<News> news;
    private List<TravelNote> notes;
}
