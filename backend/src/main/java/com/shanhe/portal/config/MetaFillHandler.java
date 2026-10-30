package com.shanhe.portal.config;

import com.baomidou.mybatisplus.core.handlers.MetaObjectHandler;
import org.apache.ibatis.reflection.MetaObject;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * 为带 createdAt / updatedAt 的实体补时间。没有对应字段的表会自动跳过。
 */
@Component
public class MetaFillHandler implements MetaObjectHandler {

    @Override
    public void insertFill(MetaObject metaObject) {
        LocalDateTime now = LocalDateTime.now();
        fillIfNull(metaObject, "createdAt", now);
        fillIfNull(metaObject, "updatedAt", now);
    }

    @Override
    public void updateFill(MetaObject metaObject) {
        if (metaObject.hasSetter("updatedAt")) {
            setFieldValByName("updatedAt", LocalDateTime.now(), metaObject);
        }
    }

    private void fillIfNull(MetaObject metaObject, String field, LocalDateTime value) {
        if (metaObject.hasSetter(field) && getFieldValByName(field, metaObject) == null) {
            setFieldValByName(field, value, metaObject);
        }
    }
}
