-- 已有 shanhe 库的增量迁移。不要整库重导。
-- scripts/apply_migrate_v4.py 会跳过已经存在的列和约束，本文件也可手工逐条执行。
-- 再次导入 schema.sql 会删除全部业务数据，只适合初始化或故意重置。

ALTER TABLE `user`
  ADD COLUMN `token_version` INT NOT NULL DEFAULT 0 COMMENT '令牌版本，修改密码后加一，旧令牌失效' AFTER `status`;

ALTER TABLE `user` ADD CONSTRAINT `chk_user_role` CHECK (`role` IN ('USER', 'ADMIN'));
ALTER TABLE `user` ADD CONSTRAINT `chk_user_status` CHECK (`status` IN (0, 1));

ALTER TABLE scenic_spot
  MODIFY `price_from` DECIMAL(10,2) DEFAULT NULL COMMENT '起价，取在售票最低价；没有在售票时为空，前台显示暂无可预约门票';
ALTER TABLE scenic_spot ADD CONSTRAINT `chk_spot_price` CHECK (`price_from` IS NULL OR `price_from` >= 0);
ALTER TABLE scenic_spot ADD CONSTRAINT `chk_spot_status` CHECK (`status` IN (0, 1));

ALTER TABLE ticket_type ADD CONSTRAINT `chk_ticket_price` CHECK (`price` >= 0);
ALTER TABLE ticket_type ADD CONSTRAINT `chk_ticket_stock` CHECK (`daily_stock` >= 0);
ALTER TABLE ticket_type ADD CONSTRAINT `chk_ticket_status` CHECK (`status` IN (0, 1));

ALTER TABLE route ADD CONSTRAINT `chk_route_days` CHECK (`days` >= 1);
ALTER TABLE route ADD CONSTRAINT `chk_route_price` CHECK (`price_from` >= 0);
ALTER TABLE route ADD CONSTRAINT `chk_route_status` CHECK (`status` IN (0, 1));

ALTER TABLE route_spot ADD CONSTRAINT `chk_stop_day` CHECK (`day_no` >= 1);

ALTER TABLE news ADD CONSTRAINT `chk_news_status` CHECK (`status` IN (0, 1));
ALTER TABLE banner ADD CONSTRAINT `chk_banner_status` CHECK (`status` IN (0, 1));

ALTER TABLE booking_order ADD CONSTRAINT `chk_order_qty` CHECK (`quantity` > 0);
ALTER TABLE booking_order ADD CONSTRAINT `chk_order_status` CHECK (`status` IN ('PENDING', 'COMPLETED', 'CANCELLED'));

-- 起价与在售票最低价对齐。没有在售票的景点写成 NULL。
UPDATE scenic_spot s
LEFT JOIN (
  SELECT spot_id, MIN(price) AS min_price
  FROM ticket_type
  WHERE status = 1
  GROUP BY spot_id
) t ON t.spot_id = s.id
SET s.price_from = t.min_price;
