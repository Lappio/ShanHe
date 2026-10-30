package com.shanhe.portal.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shanhe.portal.entity.TicketType;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

public interface TicketTypeMapper extends BaseMapper<TicketType> {
    @Select("SELECT * FROM ticket_type WHERE id = #{id} FOR UPDATE")
    TicketType lockById(@Param("id") Long id);
}
