package com.shanhe.portal.common;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.Data;

import java.util.List;

@Data
public class PageResult<T> {
    private long total;
    private long page;
    private long size;
    private List<T> records;

    public static <T> PageResult<T> of(Page<T> page) {
        PageResult<T> result = new PageResult<>();
        result.total = page.getTotal();
        result.page = page.getCurrent();
        result.size = page.getSize();
        result.records = page.getRecords();
        return result;
    }
}
