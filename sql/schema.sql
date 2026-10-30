-- 山河纪 · 全国热门景点文旅门户
-- MySQL 8.0 / utf8mb4
-- 表结构说明见 docs/网站设计报告.md 数据库设计章节

CREATE DATABASE IF NOT EXISTS shanhe DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE shanhe;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS note_like;
DROP TABLE IF EXISTS favorite;
DROP TABLE IF EXISTS comment;
DROP TABLE IF EXISTS booking_order;
DROP TABLE IF EXISTS route_spot;
DROP TABLE IF EXISTS travel_note;
DROP TABLE IF EXISTS ticket_type;
DROP TABLE IF EXISTS spot_image;
DROP TABLE IF EXISTS scenic_spot;
DROP TABLE IF EXISTS route;
DROP TABLE IF EXISTS spot_category;
DROP TABLE IF EXISTS news;
DROP TABLE IF EXISTS banner;
DROP TABLE IF EXISTS `user`;

SET FOREIGN_KEY_CHECKS = 1;

-- 用户。角色分为游客 USER 与管理员 ADMIN。
CREATE TABLE `user` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` VARCHAR(50) NOT NULL COMMENT '登录用户名，唯一',
  `password` VARCHAR(100) NOT NULL COMMENT 'BCrypt 密码哈希',
  `nickname` VARCHAR(50) NOT NULL COMMENT '显示昵称',
  `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号',
  `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
  `avatar` VARCHAR(255) DEFAULT NULL COMMENT '头像地址，可为站内路径或媒体包 URL',
  `role` VARCHAR(20) NOT NULL DEFAULT 'USER' COMMENT '角色：USER 游客，ADMIN 管理员',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1 正常，0 禁用',
  `token_version` INT NOT NULL DEFAULT 0 COMMENT '令牌版本，修改密码后加一，旧令牌失效',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '资料更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_username` (`username`),
  KEY `idx_user_role_status` (`role`, `status`),
  KEY `idx_user_created` (`created_at`),
  CONSTRAINT `chk_user_role` CHECK (`role` IN ('USER', 'ADMIN')),
  CONSTRAINT `chk_user_status` CHECK (`status` IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 景点分类，如历史古迹、自然风光。
CREATE TABLE spot_category (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` VARCHAR(40) NOT NULL COMMENT '分类名称',
  `description` VARCHAR(255) DEFAULT NULL COMMENT '分类说明',
  `icon` VARCHAR(40) DEFAULT NULL COMMENT '前端图标标识或单字印记',
  `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序，小的在前',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_category_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='景点分类表';

-- 景点主表。封面、图集与视频地址都是数据：/media/images/*.webp 与 video_url。
CREATE TABLE scenic_spot (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `category_id` BIGINT NOT NULL COMMENT '所属分类',
  `name` VARCHAR(80) NOT NULL COMMENT '景点名称',
  `province` VARCHAR(40) NOT NULL COMMENT '省级行政区',
  `city` VARCHAR(40) NOT NULL COMMENT '城市或州盟',
  `address` VARCHAR(255) NOT NULL COMMENT '详细地址',
  `longitude` DECIMAL(10,6) DEFAULT NULL COMMENT '经度',
  `latitude` DECIMAL(10,6) DEFAULT NULL COMMENT '纬度',
  `open_time` VARCHAR(255) DEFAULT NULL COMMENT '开放时间说明',
  `summary` VARCHAR(500) NOT NULL COMMENT '列表页短介绍',
  `detail` TEXT COMMENT '详情页正文',
  `cover_url` VARCHAR(500) DEFAULT NULL COMMENT '封面图地址，站内路径或外链',
  `video_url` VARCHAR(500) DEFAULT NULL COMMENT '介绍视频地址，空则前端仅展示播放器与封面',
  `video_credit` VARCHAR(255) DEFAULT NULL COMMENT '视频作者、来源与许可说明',
  `price_from` DECIMAL(10,2) DEFAULT NULL COMMENT '起价，取在售票最低价；没有在售票时为空，前台显示暂无可预约门票',
  `rating` DECIMAL(2,1) NOT NULL DEFAULT 4.5 COMMENT '展示评分，1.0-5.0',
  `visit_count` INT NOT NULL DEFAULT 0 COMMENT '热度计数，详情访问时递增',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1 上架，0 下架',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_spot_category` (`category_id`),
  KEY `idx_spot_province` (`province`),
  KEY `idx_spot_status` (`status`),
  KEY `idx_spot_price` (`price_from`),
  KEY `idx_spot_visit` (`visit_count`),
  KEY `idx_spot_filter` (`status`, `category_id`, `province`),
  CONSTRAINT `fk_spot_category` FOREIGN KEY (`category_id`) REFERENCES spot_category (`id`),
  CONSTRAINT `chk_spot_price` CHECK (`price_from` IS NULL OR `price_from` >= 0),
  CONSTRAINT `chk_spot_status` CHECK (`status` IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='景点表';

-- 景点图集。一行一张图，排序后即画廊顺序。
CREATE TABLE spot_image (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `spot_id` BIGINT NOT NULL COMMENT '所属景点',
  `url` VARCHAR(500) NOT NULL COMMENT '图片地址，站内路径或外链',
  `caption` VARCHAR(120) DEFAULT NULL COMMENT '图片说明',
  `credit` VARCHAR(255) DEFAULT NULL COMMENT '作者与许可说明，媒体包可写入',
  `sort_order` INT NOT NULL DEFAULT 0 COMMENT '画廊排序，小的在前',
  PRIMARY KEY (`id`),
  KEY `idx_image_spot` (`spot_id`, `sort_order`),
  CONSTRAINT `fk_image_spot` FOREIGN KEY (`spot_id`) REFERENCES scenic_spot (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='景点图片表';

-- 票种。一个景点可有多张票，价格与每日库存独立。
CREATE TABLE ticket_type (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `spot_id` BIGINT NOT NULL COMMENT '所属景点',
  `name` VARCHAR(60) NOT NULL COMMENT '票种名称',
  `price` DECIMAL(10,2) NOT NULL COMMENT '单价，单位元',
  `description` VARCHAR(255) DEFAULT NULL COMMENT '适用人群与包含项目',
  `daily_stock` INT NOT NULL DEFAULT 1000 COMMENT '单日可预约库存',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1 在售，0 停售',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_ticket_spot` (`spot_id`, `status`),
  CONSTRAINT `fk_ticket_spot` FOREIGN KEY (`spot_id`) REFERENCES scenic_spot (`id`),
  CONSTRAINT `chk_ticket_price` CHECK (`price` >= 0),
  CONSTRAINT `chk_ticket_stock` CHECK (`daily_stock` >= 0),
  CONSTRAINT `chk_ticket_status` CHECK (`status` IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='票种表';

-- 推荐路线。
CREATE TABLE route (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title` VARCHAR(80) NOT NULL COMMENT '路线标题',
  `days` INT NOT NULL COMMENT '行程天数',
  `cover_url` VARCHAR(500) DEFAULT NULL COMMENT '封面图地址',
  `summary` VARCHAR(500) NOT NULL COMMENT '列表摘要',
  `detail` TEXT COMMENT '行程说明正文',
  `price_from` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '参考起价，单位元',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1 发布，0 下线',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_route_status` (`status`),
  CONSTRAINT `chk_route_days` CHECK (`days` >= 1),
  CONSTRAINT `chk_route_price` CHECK (`price_from` >= 0),
  CONSTRAINT `chk_route_status` CHECK (`status` IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='推荐路线表';

-- 路线与景点的多对多关系，带天数和顺序。
CREATE TABLE route_spot (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `route_id` BIGINT NOT NULL COMMENT '路线',
  `spot_id` BIGINT NOT NULL COMMENT '景点',
  `day_no` INT NOT NULL COMMENT '第几天，从 1 开始',
  `sort_order` INT NOT NULL DEFAULT 1 COMMENT '当天内的游览顺序',
  `stay_note` VARCHAR(255) DEFAULT NULL COMMENT '当日停留说明',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_route_spot_order` (`route_id`, `day_no`, `sort_order`),
  KEY `idx_route_spot_spot` (`spot_id`),
  CONSTRAINT `fk_rs_route` FOREIGN KEY (`route_id`) REFERENCES route (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rs_spot` FOREIGN KEY (`spot_id`) REFERENCES scenic_spot (`id`),
  CONSTRAINT `chk_stop_day` CHECK (`day_no` >= 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='路线景点关联表';

-- 游记攻略。发布后默认待审核。
CREATE TABLE travel_note (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` BIGINT NOT NULL COMMENT '作者',
  `spot_id` BIGINT DEFAULT NULL COMMENT '关联景点，可空',
  `title` VARCHAR(120) NOT NULL COMMENT '标题',
  `cover_url` VARCHAR(500) DEFAULT NULL COMMENT '封面图地址',
  `content` TEXT NOT NULL COMMENT '正文，按纯文本保存',
  `status` VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '审核状态：PENDING 待审，APPROVED 通过，REJECTED 驳回',
  `reject_reason` VARCHAR(255) DEFAULT NULL COMMENT '驳回原因',
  `like_count` INT NOT NULL DEFAULT 0 COMMENT '点赞数冗余，与 note_like 同步',
  `view_count` INT NOT NULL DEFAULT 0 COMMENT '阅读数',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后编辑时间',
  PRIMARY KEY (`id`),
  KEY `idx_note_status_created` (`status`, `created_at`),
  KEY `idx_note_user` (`user_id`),
  KEY `idx_note_spot` (`spot_id`),
  CONSTRAINT `fk_note_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `fk_note_spot` FOREIGN KEY (`spot_id`) REFERENCES scenic_spot (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='游记攻略表';

-- 游记点赞。同一用户对同一游记只能有一行。
CREATE TABLE note_like (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `note_id` BIGINT NOT NULL COMMENT '游记',
  `user_id` BIGINT NOT NULL COMMENT '点赞用户',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_note_like` (`note_id`, `user_id`),
  KEY `idx_like_user` (`user_id`),
  CONSTRAINT `fk_like_note` FOREIGN KEY (`note_id`) REFERENCES travel_note (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_like_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='游记点赞表';

-- 评论。target_type + target_id 指向景点或游记，故不对 target_id 建外键。
CREATE TABLE comment (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` BIGINT NOT NULL COMMENT '评论用户',
  `target_type` VARCHAR(20) NOT NULL COMMENT '目标类型：SPOT 景点，NOTE 游记',
  `target_id` BIGINT NOT NULL COMMENT '目标主键',
  `content` VARCHAR(500) NOT NULL COMMENT '评论内容',
  `status` VARCHAR(20) NOT NULL DEFAULT 'VISIBLE' COMMENT '状态：VISIBLE 展示，HIDDEN 隐藏',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评论时间',
  PRIMARY KEY (`id`),
  KEY `idx_comment_target` (`target_type`, `target_id`, `status`),
  KEY `idx_comment_user` (`user_id`),
  CONSTRAINT `fk_comment_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论表';

-- 收藏。可收藏景点、路线或游记。
CREATE TABLE favorite (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` BIGINT NOT NULL COMMENT '用户',
  `target_type` VARCHAR(20) NOT NULL COMMENT '目标类型：SPOT 景点，ROUTE 路线，NOTE 游记',
  `target_id` BIGINT NOT NULL COMMENT '目标主键',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_favorite` (`user_id`, `target_type`, `target_id`),
  KEY `idx_favorite_target` (`target_type`, `target_id`),
  CONSTRAINT `fk_fav_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收藏表';

-- 资讯公告。
CREATE TABLE news (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title` VARCHAR(120) NOT NULL COMMENT '标题',
  `cover_url` VARCHAR(500) DEFAULT NULL COMMENT '封面图地址',
  `summary` VARCHAR(500) NOT NULL COMMENT '摘要',
  `content` TEXT NOT NULL COMMENT '正文',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1 发布，0 草稿',
  `published_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_news_status_pub` (`status`, `published_at`),
  CONSTRAINT `chk_news_status` CHECK (`status` IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='资讯公告表';

-- 首页轮播。
CREATE TABLE banner (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title` VARCHAR(80) NOT NULL COMMENT '主标题',
  `subtitle` VARCHAR(160) DEFAULT NULL COMMENT '副标题',
  `image_url` VARCHAR(500) NOT NULL COMMENT '背景图地址',
  `link_url` VARCHAR(255) DEFAULT NULL COMMENT '点击跳转，站内路径或外链',
  `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序，小的在前',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1 启用，0 停用',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_banner_status_sort` (`status`, `sort_order`),
  CONSTRAINT `chk_banner_status` CHECK (`status` IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='首页轮播表';

-- 门票预约订单。
CREATE TABLE booking_order (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_no` VARCHAR(32) NOT NULL COMMENT '业务订单号',
  `user_id` BIGINT NOT NULL COMMENT '下单用户',
  `spot_id` BIGINT NOT NULL COMMENT '景点',
  `ticket_type_id` BIGINT NOT NULL COMMENT '票种',
  `visit_date` DATE NOT NULL COMMENT '游玩日期',
  `quantity` INT NOT NULL COMMENT '数量',
  `unit_price` DECIMAL(10,2) NOT NULL COMMENT '下单时单价快照',
  `total_amount` DECIMAL(10,2) NOT NULL COMMENT '订单金额',
  `contact_name` VARCHAR(50) NOT NULL COMMENT '联系人姓名',
  `contact_phone` VARCHAR(20) NOT NULL COMMENT '联系人手机',
  `status` VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '状态：PENDING 待出行，COMPLETED 已完成，CANCELLED 已取消',
  `remark` VARCHAR(255) DEFAULT NULL COMMENT '备注',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '下单时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '状态变更时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_order_user` (`user_id`, `created_at`),
  KEY `idx_order_spot` (`spot_id`),
  KEY `idx_order_ticket_date` (`ticket_type_id`, `visit_date`, `status`),
  KEY `idx_order_status_created` (`status`, `created_at`),
  CONSTRAINT `fk_order_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `fk_order_spot` FOREIGN KEY (`spot_id`) REFERENCES scenic_spot (`id`),
  CONSTRAINT `fk_order_ticket` FOREIGN KEY (`ticket_type_id`) REFERENCES ticket_type (`id`),
  CONSTRAINT `chk_order_qty` CHECK (`quantity` > 0),
  CONSTRAINT `chk_order_status` CHECK (`status` IN ('PENDING', 'COMPLETED', 'CANCELLED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='门票预约订单表';

-- 与 backend/src/main/resources/application.yml 中的账号一致。
-- Docker Compose 的后端仍使用 root，不受这三行影响。
CREATE USER IF NOT EXISTS 'shanhe'@'localhost' IDENTIFIED BY 'shanhe123';
CREATE USER IF NOT EXISTS 'shanhe'@'127.0.0.1' IDENTIFIED BY 'shanhe123';
CREATE USER IF NOT EXISTS 'shanhe'@'%' IDENTIFIED BY 'shanhe123';
GRANT ALL PRIVILEGES ON shanhe.* TO 'shanhe'@'localhost';
GRANT ALL PRIVILEGES ON shanhe.* TO 'shanhe'@'127.0.0.1';
GRANT ALL PRIVILEGES ON shanhe.* TO 'shanhe'@'%';
FLUSH PRIVILEGES;
