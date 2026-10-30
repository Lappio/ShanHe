#!/usr/bin/env python3
"""走一遍课程要求的主流程，打印每一步的业务码。"""
import json
import time
import urllib.parse
import urllib.request
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

# 只访问后端 HTTP。8088 是 application.yml 和 Compose 的默认宿主机端口（SHANHE_BACKEND_PORT）。
BASE = "http://127.0.0.1:8088/api"


def call(method, path, body=None, token=None):
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(BASE + path, data=data, method=method)
    req.add_header("Content-Type", "application/json")
    if token:
        req.add_header("Authorization", "Bearer " + token)
    with urllib.request.urlopen(req) as resp:
        payload = json.loads(resp.read().decode())
    if payload["code"] != 0:
        raise SystemExit(f"FAIL {method} {path} -> {payload}")
    return payload["data"]


def main():
    spots = call("GET", "/spots?keyword=" + urllib.parse.quote("西湖") + "&size=5")
    assert any("西湖" in item["name"] for item in spots["records"])
    detail = call("GET", "/spots/1")
    ticket = detail["tickets"][0]
    username = "e2e" + time.strftime("%H%M%S")
    reg = call("POST", "/auth/register", {
        "username": username, "password": "user12345", "nickname": "验收访客", "phone": "13900001111",
    })
    token = reg["token"]
    order = call("POST", "/orders", {
        "spotId": detail["spot"]["id"],
        "ticketTypeId": ticket["id"],
        "visitDate": (datetime.now(ZoneInfo("Asia/Shanghai")).date() + timedelta(days=7)).isoformat(),
        "quantity": 2,
        "contactName": "验收访客",
        "contactPhone": "13900001111",
    }, token)
    print("order", order["orderNo"], order["status"], order["totalAmount"])
    mine = call("GET", "/orders/mine", token=token)
    assert any(item["orderNo"] == order["orderNo"] for item in mine["records"])
    call("PUT", f"/orders/{order['id']}/cancel", token=token)
    cancelled = call("GET", "/orders/mine?status=CANCELLED", token=token)
    assert any(item["id"] == order["id"] for item in cancelled["records"])
    note_id = call("POST", "/notes", {
        "title": "验收游记：中轴线半日",
        "content": "这是接口验收自动写下的游记。从午门走到神武门，红墙比照片里更宽，时间要留够半天。",
        "spotId": 1,
    }, token)
    admin = call("POST", "/auth/login", {"username": "admin", "password": "admin123"})
    pending = call("GET", "/admin/notes?status=PENDING&size=20", token=admin["token"])
    assert any(item["id"] == note_id for item in pending["records"])
    call("PUT", f"/admin/notes/{note_id}/audit", {"status": "APPROVED"}, admin["token"])
    public = call("GET", f"/notes/{note_id}")
    assert public["status"] == "APPROVED"
    stats = call("GET", "/admin/stats", token=admin["token"])
    print("stats", stats["userCount"], stats["orderCount"], stats["pendingNotes"], len(stats["trendDays"]))
    print("E2E_OK", username, order["orderNo"], note_id)


if __name__ == "__main__":
    main()
