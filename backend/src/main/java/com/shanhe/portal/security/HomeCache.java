package com.shanhe.portal.security;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.stereotype.Component;

/** 内容变更后清掉首页聚合缓存。单独放一个 Bean，避免同类自调用导致注解失效。 */
@Component
public class HomeCache {
    @CacheEvict(value = "home", allEntries = true)
    public void evict() {
        // 缓存清理由注解完成
    }
}
