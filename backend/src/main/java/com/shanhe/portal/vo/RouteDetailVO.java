package com.shanhe.portal.vo;

import com.shanhe.portal.entity.RouteSpot;
import com.shanhe.portal.entity.TourRoute;
import lombok.Data;

import java.util.List;

@Data
public class RouteDetailVO {
    private TourRoute route;
    private List<RouteSpot> stops;
    private boolean favorited;
}
