package com.shanhe.portal.vo;

import com.shanhe.portal.entity.ScenicSpot;
import com.shanhe.portal.entity.SpotImage;
import com.shanhe.portal.entity.TicketType;
import lombok.Data;

import java.util.List;

@Data
public class SpotDetailVO {
    private ScenicSpot spot;
    private List<SpotImage> images;
    private List<TicketType> tickets;
    private long commentCount;
}
