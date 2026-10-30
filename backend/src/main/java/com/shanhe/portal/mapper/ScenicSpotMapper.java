package com.shanhe.portal.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shanhe.portal.entity.ScenicSpot;
import org.apache.ibatis.annotations.Select;

import java.util.List;

public interface ScenicSpotMapper extends BaseMapper<ScenicSpot> {
    @Select("SELECT DISTINCT province FROM scenic_spot WHERE status = 1 ORDER BY CONVERT(province USING gbk)")
    List<String> selectProvinces();
}
