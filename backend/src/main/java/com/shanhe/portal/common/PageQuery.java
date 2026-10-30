package com.shanhe.portal.common;

import lombok.Data;

@Data
public class PageQuery {
    private long page = 1;
    private long size = 10;

    public long pageNo() {
        return page < 1 ? 1 : page;
    }

    public long pageSize(long defaultSize, long max) {
        return clampSize(size, defaultSize, max);
    }

    public static long clampPage(long page) {
        return page < 1 ? 1 : page;
    }

    public static long clampSize(long size, long defaultSize) {
        return clampSize(size, defaultSize, 50);
    }

    public static long clampSize(long size, long defaultSize, long max) {
        long cap = max < 1 ? 1 : max;
        long value = size < 1 ? defaultSize : size;
        if (value < 1) {
            value = 1;
        }
        return Math.min(value, cap);
    }
}
