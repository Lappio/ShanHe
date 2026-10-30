package com.shanhe.portal;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

import java.util.TimeZone;

/**
 * 山河纪后端入口。时区固定为上海，保证预约日期与统计窗口和导入数据一致。
 */
@SpringBootApplication
@MapperScan("com.shanhe.portal.mapper")
@EnableCaching
public class PortalApplication {

    public static void main(String[] args) {
        TimeZone.setDefault(TimeZone.getTimeZone("Asia/Shanghai"));
        SpringApplication.run(PortalApplication.class, args);
    }
}
