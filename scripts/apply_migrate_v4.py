#!/usr/bin/env python3
"""给已经导入的 shanhe 库补 token_version、可空起价和 CHECK。可重复执行。

默认连本机 MySQL 127.0.0.1:3306。Docker Compose 把 MySQL 发布在
SHANHE_MYSQL_PORT（默认 13306）；连那个库时设置 SHANHE_DB_PORT，或传 --port。
"""
import argparse
import os
import subprocess

CHECKS = [
    ("user", "chk_user_role", "ALTER TABLE `user` ADD CONSTRAINT `chk_user_role` CHECK (`role` IN ('USER', 'ADMIN'))"),
    ("user", "chk_user_status", "ALTER TABLE `user` ADD CONSTRAINT `chk_user_status` CHECK (`status` IN (0, 1))"),
    ("scenic_spot", "chk_spot_price", "ALTER TABLE scenic_spot ADD CONSTRAINT `chk_spot_price` CHECK (`price_from` IS NULL OR `price_from` >= 0)"),
    ("scenic_spot", "chk_spot_status", "ALTER TABLE scenic_spot ADD CONSTRAINT `chk_spot_status` CHECK (`status` IN (0, 1))"),
    ("ticket_type", "chk_ticket_price", "ALTER TABLE ticket_type ADD CONSTRAINT `chk_ticket_price` CHECK (`price` >= 0)"),
    ("ticket_type", "chk_ticket_stock", "ALTER TABLE ticket_type ADD CONSTRAINT `chk_ticket_stock` CHECK (`daily_stock` >= 0)"),
    ("ticket_type", "chk_ticket_status", "ALTER TABLE ticket_type ADD CONSTRAINT `chk_ticket_status` CHECK (`status` IN (0, 1))"),
    ("route", "chk_route_days", "ALTER TABLE route ADD CONSTRAINT `chk_route_days` CHECK (`days` >= 1)"),
    ("route", "chk_route_price", "ALTER TABLE route ADD CONSTRAINT `chk_route_price` CHECK (`price_from` >= 0)"),
    ("route", "chk_route_status", "ALTER TABLE route ADD CONSTRAINT `chk_route_status` CHECK (`status` IN (0, 1))"),
    ("route_spot", "chk_stop_day", "ALTER TABLE route_spot ADD CONSTRAINT `chk_stop_day` CHECK (`day_no` >= 1)"),
    ("news", "chk_news_status", "ALTER TABLE news ADD CONSTRAINT `chk_news_status` CHECK (`status` IN (0, 1))"),
    ("banner", "chk_banner_status", "ALTER TABLE banner ADD CONSTRAINT `chk_banner_status` CHECK (`status` IN (0, 1))"),
    ("booking_order", "chk_order_qty", "ALTER TABLE booking_order ADD CONSTRAINT `chk_order_qty` CHECK (`quantity` > 0)"),
    ("booking_order", "chk_order_status", "ALTER TABLE booking_order ADD CONSTRAINT `chk_order_status` CHECK (`status` IN ('PENDING', 'COMPLETED', 'CANCELLED'))"),
]


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default=os.environ.get("SHANHE_DB_HOST", "127.0.0.1"))
    parser.add_argument(
        "--port",
        type=int,
        default=int(os.environ.get("SHANHE_DB_PORT", "3306")),
        help="本机 MySQL 为 3306。Compose 宿主机端口见 SHANHE_MYSQL_PORT，默认 13306",
    )
    parser.add_argument("--user", default=os.environ.get("SHANHE_DB_USER", "shanhe"))
    parser.add_argument("--password", default=os.environ.get("SHANHE_DB_PASSWORD", "shanhe123"))
    parser.add_argument("--database", default=os.environ.get("SHANHE_DB_NAME", "shanhe"))
    return parser.parse_args()


def mysql(args, sql):
    env = os.environ.copy()
    env["MYSQL_PWD"] = args.password
    return subprocess.check_output(
        ["mysql", "-h", args.host, "-P", str(args.port), "-u", args.user, args.database, "-N", "-e", sql],
        text=True,
        env=env,
    ).strip()


def main():
    args = parse_args()
    has_version = mysql(
        args,
        "SELECT COUNT(*) FROM information_schema.COLUMNS "
        "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'user' AND COLUMN_NAME = 'token_version'",
    )
    if has_version == "0":
        mysql(
            args,
            "ALTER TABLE `user` ADD COLUMN `token_version` INT NOT NULL DEFAULT 0 "
            "COMMENT '令牌版本，修改密码后加一，旧令牌失效' AFTER `status`",
        )
        print("added user.token_version")
    else:
        print("user.token_version exists")
    nullable = mysql(
        args,
        "SELECT IS_NULLABLE FROM information_schema.COLUMNS "
        "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'scenic_spot' AND COLUMN_NAME = 'price_from'",
    )
    if nullable != "YES":
        mysql(
            args,
            "ALTER TABLE scenic_spot MODIFY `price_from` DECIMAL(10,2) DEFAULT NULL "
            "COMMENT '起价，取在售票最低价；没有在售票时为空，前台显示暂无可预约门票'",
        )
        print("scenic_spot.price_from now nullable")
    else:
        print("scenic_spot.price_from already nullable")
    for table, name, statement in CHECKS:
        found = mysql(
            args,
            "SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS "
            f"WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '{table}' AND CONSTRAINT_NAME = '{name}'",
        )
        if found == "0":
            mysql(args, statement)
            print("added", name)
        else:
            print("exists", name)
    # 与 SpotService.refreshPrice 相同：有在售票时起价取最低价，否则为空。
    mysql(
        args,
        "UPDATE scenic_spot s "
        "LEFT JOIN (SELECT spot_id, MIN(price) AS min_price FROM ticket_type WHERE status = 1 GROUP BY spot_id) t "
        "ON t.spot_id = s.id "
        "SET s.price_from = t.min_price",
    )
    print("scenic_spot.price_from recomputed from on-sale tickets")


if __name__ == "__main__":
    main()
