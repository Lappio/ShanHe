#!/usr/bin/env python3
"""画设计报告用的 ER 图和两张时序图。导出后每张图按版心宽度约占 0.7 页以上。"""
import os
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

OUT = Path(__file__).resolve().parents[1] / "docs" / "diagrams"
OUT.mkdir(parents=True, exist_ok=True)


def resolve_font():
    named = [os.environ.get("SHANHE_FONT", ""), os.environ.get("DIAGRAM_FONT", "")]
    named.extend([
        "/usr/share/fonts/truetype/wqy/wqy-microhei.ttc",
        "/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc",
        "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",
        "/usr/share/fonts/truetype/noto/NotoSansCJK-Regular.ttc",
        "/usr/share/fonts/noto-cjk/NotoSansCJK-Regular.ttc",
    ])
    for path in named:
        if path and os.path.isfile(path):
            return path
    for root in ("/usr/share/fonts", "/usr/local/share/fonts"):
        if not os.path.isdir(root):
            continue
        for dirpath, _dirs, files in os.walk(root):
            for name in files:
                lower = name.lower()
                if lower.endswith((".ttc", ".ttf", ".otf")) and any(
                    key in lower for key in ("wqy", "cjk", "noto", "sourcehan", "droid")
                ):
                    return os.path.join(dirpath, name)
    sys.exit("找不到中文字体。请安装 fonts-wqy-microhei，或设置环境变量 SHANHE_FONT 指向 .ttf/.ttc。未找到字体时不会写图片。")


FONT = resolve_font()
INK = (28, 36, 42)
PINE = (30, 107, 88)
PAPER = (246, 241, 231)
LINE = (90, 78, 62)
GOLD = (184, 146, 74)


def font(size):
    return ImageFont.truetype(FONT, size)


def box(draw, xy, title, lines, fill=(255, 252, 246)):
    x, y, w, h = xy
    draw.rounded_rectangle((x, y, x + w, y + h), 10, fill=fill, outline=INK, width=2)
    draw.rectangle((x, y, x + w, y + 36), fill=PINE)
    draw.text((x + 12, y + 6), title, font=font(20), fill=(255, 248, 236))
    yy = y + 46
    for line in lines:
        draw.text((x + 12, yy), line, font=font(16), fill=INK)
        yy += 24


def er():
    w, h = 1600, 1980
    img = Image.new("RGB", (w, h), PAPER)
    d = ImageDraw.Draw(img)
    d.text((48, 28), "山河纪 · 十四张表的概念结构", font=font(36), fill=INK)
    d.text((48, 78), "实线表示外键。评论和收藏是多态，target_id 不建外键。banner 与 news 独立。", font=font(20), fill=LINE)

    specs = [
        (40, 140, "user 用户", ["主键 id", "用户名唯一", "角色 USER / ADMIN"]),
        (430, 140, "travel_note 游记", ["作者 user_id", "景点 spot_id 可空", "状态待审/通过/驳回"]),
        (820, 140, "note_like 点赞", ["游记 + 用户唯一", "一人一篇只能赞一次", "删除时级联"]),
        (1210, 140, "comment 评论", ["目标类型 + 目标 id", "作者 user_id", "可见或隐藏"]),
        (40, 420, "favorite 收藏", ["目标类型 + 目标 id", "与用户联合唯一", "景点/路线/游记"]),
        (430, 420, "spot_category 分类", ["六个主题", "名称、排序", "一对多景点"]),
        (820, 420, "scenic_spot 景点", ["分类 category_id", "封面、视频、署名", "起价与评分"]),
        (1210, 420, "spot_image 图集", ["景点 spot_id", "路径与 credit", "排序 sort_order"]),
        (40, 760, "ticket_type 票种", ["景点 spot_id", "单价与日库存", "下单前 FOR UPDATE"]),
        (430, 760, "booking_order 订单", ["用户、景点、票种", "游玩日期与数量", "单价快照"]),
        (820, 760, "route 路线", ["天数与价格", "封面与简介", "可被收藏"]),
        (1210, 760, "route_spot 途经", ["路线 route_id", "景点 spot_id", "第几天、顺序"]),
        (430, 1100, "news 资讯", ["标题、正文、封面", "发布时间", "无外键"]),
        (820, 1100, "banner 轮播", ["图片、标题、链接", "排序与上下架", "无外键"]),
    ]
    for x, y, title, lines in specs:
        box(d, (x, y, 350, 150), title, lines)

    d.text((48, 1320), "关系说明（与上图同一套表，按业务读）", font=font(28), fill=INK)
    notes = [
        "1. user 是账号中心。订单、游记、评论、收藏、点赞都从 user.id 出去。删除用户前要先处理订单，避免外键拦住。",
        "2. spot_category 只连接 scenic_spot。景点再分出 spot_image、ticket_type，并被订单、路线站点和游记引用。",
        "3. booking_order 同时指向 user、scenic_spot、ticket_type。金额用下单时的 unit_price，不回读现价。",
        "4. route 与 scenic_spot 是多对多，中间表 route_spot 记录第几天和第几站。",
        "5. travel_note.spot_id 可空，景点删除时置空，游记正文还在。note_like 用联合唯一键去重。",
        "6. comment 与 favorite 用 target_type 区分 SPOT、ROUTE、NOTE。target_id 由服务层检查，不建数据库外键。",
        "7. news 与 banner 不挂景点外键。首页把它们和热门景点、路线拼在同一次聚合接口里。",
        "8. 票种行在创建订单的事务里 SELECT … FOR UPDATE，再按游玩日期汇总未取消数量，避免并发超卖。",
    ]
    y = 1380
    for line in notes:
        d.text((48, y), line, font=font(22), fill=INK)
        y += 64
    img.save(OUT / "er.png", optimize=True)
    print("er", img.size)


def seq(name, title, actors, steps):
    w, h = 1500, 1880
    img = Image.new("RGB", (w, h), PAPER)
    d = ImageDraw.Draw(img)
    d.text((40, 24), title, font=font(32), fill=INK)
    n = len(actors)
    span = 1320
    left = 90
    xs = [left + int(i * span / (n - 1)) for i in range(n)]
    top = 150
    for x, actor in zip(xs, actors):
        d.rounded_rectangle((x - 70, top, x + 70, top + 48), 8, fill=PINE)
        tw = d.textlength(actor, font=font(18))
        d.text((x - tw / 2, top + 12), actor, font=font(18), fill=(255, 248, 236))
        d.line((x, top + 48, x, 1500), fill=(180, 168, 150), width=2)
    y = 240
    for i, (src, dst, text) in enumerate(steps):
        x1, x2 = xs[src], xs[dst]
        d.line((x1, y, x2, y), fill=INK, width=2)
        arrow = 10 if x2 >= x1 else -10
        d.polygon([(x2, y), (x2 - arrow, y - 6), (x2 - arrow, y + 6)], fill=PINE)
        label = f"{i + 1}. {text}"
        d.text((40, y + 10), label, font=font(20), fill=INK)
        y += 78
    img.save(OUT / name, optimize=True)
    print(name, img.size)


def main():
    er()
    seq(
        "seq-booking.png",
        "时序 · 游客预约门票",
        ["游客", "预约页", "OrderService", "MySQL"],
        [
            (0, 1, "选择上海日历中的今天至 +60 天"),
            (1, 1, "disabledDate 用 Asia/Shanghai 的年月日比较"),
            (1, 2, "POST /api/orders，携带票种、日期、数量"),
            (2, 2, "LocalDate.now(Asia/Shanghai) 再次校验日期"),
            (2, 3, "确认景点上架、票种在售且属于该景点"),
            (2, 3, "SELECT ticket_type WHERE id=? FOR UPDATE"),
            (2, 3, "SUM 已售 FOR UPDATE，超过日库存则拒绝"),
            (2, 3, "插入 booking_order，单价取锁定行的价格"),
            (3, 2, "提交事务，释放行锁"),
            (2, 1, "返回订单号，状态 PENDING"),
            (1, 0, "跳到我的订单，可取消待出行订单"),
            (0, 2, "取消后状态改为 CANCELLED，库存查询不再计入"),
        ],
    )
    seq(
        "seq-audit.png",
        "时序 · 游记审核",
        ["作者", "NoteService", "管理员", "访客"],
        [
            (0, 1, "投稿，服务强制写成 PENDING"),
            (3, 1, "公开列表只查 APPROVED，访客看不到这篇"),
            (0, 1, "作者按 id 打开，仍可阅读并看到待审标记"),
            (3, 1, "其他访客打开同一 id，返回尚未通过"),
            (2, 1, "后台待审列表里看到这篇"),
            (2, 1, "通过：状态改为 APPROVED，并清首页缓存"),
            (3, 1, "之后访客可以阅读、评论和点赞"),
            (0, 1, "作者再编辑：状态回到 PENDING，驳回原因置 NULL"),
            (3, 1, "编辑后的正文再次对访客隐藏，直到重新通过"),
            (2, 1, "若驳回且不填原因，前端对话框不允许提交"),
            (2, 1, "驳回写入 REJECTED 和 reject_reason"),
            (0, 1, "作者看到驳回原因，改完可再次提交"),
        ],
    )


if __name__ == "__main__":
    main()
