#!/usr/bin/env python3
"""两笔同时买满同一天库存，只能成功一笔。

临时把指定票种的日库存改成 6，用 linwan 和 zhouan 各买 6 张。
库存修改包在 try 里，finally 无论登录失败或线程抛错都会改回原库存。
连接参数来自命令行或环境变量，不使用 sudo mysql。
若指定游玩日已经有未取消订单，在改库存之前退出。
默认连本机 MySQL 127.0.0.1:3306。Docker Compose 的宿主机端口是
SHANHE_MYSQL_PORT（默认 13306），连那个库时设置 SHANHE_DB_PORT 或传 --port。
"""
import argparse
import json
import os
import subprocess
import threading
import urllib.error
import urllib.request
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

BASE = os.environ.get("SHANHE_API", "http://127.0.0.1:8088/api")


def parse_args():
    parser = argparse.ArgumentParser(description="并发预约超卖检查")
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
    parser.add_argument("--ticket-id", type=int, default=int(os.environ.get("SHANHE_TICKET_ID", "1")))
    parser.add_argument("--visit", default="", help="游玩日期 YYYY-MM-DD，默认上海今天加 20 天")
    parser.add_argument("--fail-after-stock", action="store_true", help="改库存后故意失败，用来确认 finally 会还原")
    return parser.parse_args()


def mysql(args, sql):
    env = os.environ.copy()
    env["MYSQL_PWD"] = args.password
    out = subprocess.check_output(
        [
            "mysql",
            "-h", args.host,
            "-P", str(args.port),
            "-u", args.user,
            args.database,
            "-N",
            "-e", sql,
        ],
        text=True,
        env=env,
    )
    return out.strip()


def call(method, path, body=None, token=None):
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(BASE + path, data=data, method=method)
    req.add_header("Content-Type", "application/json")
    if token:
        req.add_header("Authorization", "Bearer " + token)
    try:
        with urllib.request.urlopen(req) as resp:
            raw = resp.read().decode()
            status = resp.status
    except urllib.error.HTTPError as exc:
        raw = exc.read().decode()
        status = exc.code
    payload = json.loads(raw)
    payload["_http"] = status
    return payload


def login(username):
    payload = call("POST", "/auth/login", {"username": username, "password": "user123"})
    if payload["code"] != 0:
        raise SystemExit(f"login {username} failed: {payload}")
    return payload["data"]["token"]


def main():
    args = parse_args()
    visit = args.visit or (datetime.now(ZoneInfo("Asia/Shanghai")).date() + timedelta(days=20)).isoformat()
    ticket_id = args.ticket_id
    original = mysql(args, f"SELECT daily_stock FROM ticket_type WHERE id = {ticket_id}")
    spot_id = mysql(args, f"SELECT spot_id FROM ticket_type WHERE id = {ticket_id}")
    sold = mysql(
        args,
        "SELECT COALESCE(SUM(quantity),0) FROM booking_order "
        f"WHERE ticket_type_id = {ticket_id} AND visit_date = '{visit}' AND status <> 'CANCELLED'",
    )
    print("before", "stock", original, "sold", sold, "visit", visit)
    if sold != "0":
        raise SystemExit("该日已有订单，换一天再测")
    changed = False
    ok = []
    tokens = {}
    try:
        mysql(args, f"UPDATE ticket_type SET daily_stock = 6 WHERE id = {ticket_id}")
        changed = True
        if args.fail_after_stock:
            raise SystemExit("deliberate failure after stock change")
        tokens = {"linwan": login("linwan"), "zhouan": login("zhouan")}
        barrier = threading.Barrier(2)
        results = {}

        def buy(username):
            barrier.wait()
            results[username] = call(
                "POST",
                "/orders",
                {
                    "spotId": int(spot_id),
                    "ticketTypeId": ticket_id,
                    "visitDate": visit,
                    "quantity": 6,
                    "contactName": username,
                    "contactPhone": "13800001001" if username == "linwan" else "13800001002",
                },
                tokens[username],
            )

        threads = [threading.Thread(target=buy, args=(name,)) for name in tokens]
        for thread in threads:
            thread.start()
        for thread in threads:
            thread.join()
        failed = []
        for name, payload in results.items():
            data = payload.get("data") or {}
            print(name, payload.get("code"), payload.get("message"), data.get("orderNo"))
            if payload.get("code") == 0:
                ok.append((name, data.get("orderNo"), data.get("id")))
            else:
                failed.append((name, payload.get("message")))
        if len(ok) != 1 or len(failed) != 1:
            raise SystemExit(f"FAIL expected one success, got ok={ok} failed={failed}")
        if "余票" not in (failed[0][1] or ""):
            raise SystemExit("FAIL second booking was not a stock rejection: " + str(failed[0][1]))
        extra = call(
            "POST",
            "/orders",
            {
                "spotId": int(spot_id),
                "ticketTypeId": ticket_id,
                "visitDate": visit,
                "quantity": 1,
                "contactName": "linwan",
                "contactPhone": "13800001001",
            },
            tokens["linwan"],
        )
        print("extra", extra.get("code"), extra.get("message"))
        if extra.get("code") == 0:
            ok.append(("linwan-extra", extra.get("data", {}).get("orderNo"), extra.get("data", {}).get("id")))
            raise SystemExit("FAIL a third ticket was sold after stock was full")
        print("OVERSELL_OK", ok[0][1], "rejected", failed[0][0])
    finally:
        if changed:
            for name, _order_no, order_id in ok:
                if order_id and name in tokens:
                    call("PUT", f"/orders/{order_id}/cancel", token=tokens[name])
            mysql(args, f"UPDATE ticket_type SET daily_stock = {original} WHERE id = {ticket_id}")
            print("restored stock", original)


if __name__ == "__main__":
    main()
