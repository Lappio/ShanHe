#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""生成 sql/data.sql。景点图、横幅和视频地址来自 docs/media-manifest.json。

图片文件放在 frontend/public/media/images/，与 manifest 里的 file 字段对应。
封面用缩略图，画廊用大图，video_url 只在 manifest 提供时写入。
本地介绍视频放在 frontend/public/media/videos/<slug>.mp4，地址写成 /media/videos/<slug>.mp4。
重新生成种子时不要删除 videos/，否则清单里的本地地址会指向空文件。
"""
import colorsys
import json
import shutil
from pathlib import Path

import bcrypt

ROOT = Path(__file__).resolve().parents[1]
MEDIA = ROOT / "frontend" / "public" / "media"

NS = "http://www.w3.org/2000/svg"


def q(value):
    if value is None:
        return "NULL"
    return "'" + str(value).replace("\\", "\\\\").replace("'", "''") + "'"


def hex_color(h, s, l):
    r, g, b = colorsys.hls_to_rgb((h % 360) / 360.0, max(0, min(1, l)), max(0, min(1, s)))
    return "#{:02x}{:02x}{:02x}".format(int(r * 255), int(g * 255), int(b * 255))


PALETTE = {
    "palace": ("#1d3550", "#c4553a", "#e6c27a", "#6e2430"),
    "wall": ("#243044", "#c9843d", "#d7c4a3", "#2c241c"),
    "garden": ("#1f4d45", "#c4a36a", "#d7ece4", "#24574a"),
    "lake": ("#1c4c6b", "#e7d3a1", "#d5eef5", "#16384a"),
    "mountain": ("#1e3d4c", "#d7c4a3", "#c5d2c4", "#1c2e28"),
    "tomb": ("#3a332c", "#c2a37a", "#e6d3b0", "#2a211c"),
    "river": ("#1a4a52", "#9fd3c7", "#e7efe4", "#16343a"),
    "coast": ("#1f5f8a", "#f2c14e", "#f6e3c0", "#1a4e68"),
    "town": ("#3d2a2a", "#e0b07a", "#f3e6d4", "#5c2e2a"),
    "grass": ("#2f6a4a", "#e6d48a", "#cfe6b0", "#24543a"),
    "grotto": ("#3a3428", "#d8c3a5", "#cbb89a", "#2c241c"),
    "waterfall": ("#1d3f46", "#d5e6ea", "#eef6f7", "#163238"),
    "snow": ("#2c4a66", "#d5e4f0", "#f4f8fb", "#24384a"),
    "city": ("#1b2430", "#c6a15b", "#9eb0c2", "#141b24"),
}


def _stamp(w, h, mark):
    x, y = w - 58, h - 58
    return f'''<g transform="translate({x},{y})">
      <circle r="26" fill="#9c2f24"/>
      <circle r="22" fill="none" stroke="#f0d7a2" stroke-width="1.4"/>
      <text y="7" text-anchor="middle" fill="#f6e7c1" font-size="20" font-family="STSong,SimSun,serif">{mark}</text>
    </g>'''


def _draw(scene, w, h, accent, light, deep, variant):
    s = 1 + variant * 0.03
    if scene in ("mountain", "wall"):
        body = f'''
        <path d="M0 {h*0.78} L{w*0.15} {h*0.50} L{w*0.28} {h*0.66} L{w*0.46} {h*(0.36/s)} L{w*0.62} {h*0.64} L{w*0.78} {h*0.46} L{w} {h*0.70} V{h} H0 Z" fill="{deep}" opacity="0.45"/>
        <path d="M0 {h*0.84} L{w*0.2} {h*0.58} L{w*0.38} {h*0.76} L{w*0.55} {h*0.50} L{w*0.74} {h*0.72} L{w} {h*0.60} V{h} H0 Z" fill="{deep}"/>
        <path d="M0 {h*0.92} C {w*0.3} {h*0.86}, {w*0.6} {h*0.98}, {w} {h*0.88} V{h} H0 Z" fill="{accent}" opacity="0.45"/>'''
        if scene == "wall":
            body += f'''<polyline points="{w*0.18},{h*0.60} {w*0.28},{h*0.52} {w*0.36},{h*0.58} {w*0.46},{h*0.47} {w*0.56},{h*0.56} {w*0.66},{h*0.46} {w*0.76},{h*0.54}" fill="none" stroke="{accent}" stroke-width="6" stroke-linejoin="round"/>'''
        return body
    if scene == "palace":
        return f'''
        <rect x="{w*0.06}" y="{h*0.74}" width="{w*0.88}" height="{h*0.05}" fill="{accent}"/>
        <polygon points="{w*0.10},{h*0.62} {w*0.50},{h*0.38} {w*0.90},{h*0.62}" fill="{light}"/>
        <polygon points="{w*0.16},{h*0.62} {w*0.50},{h*0.46} {w*0.84},{h*0.62}" fill="{accent}"/>
        <rect x="{w*0.22}" y="{h*0.62}" width="{w*0.56}" height="{h*0.16}" fill="{deep}"/>
        <g fill="{light}">
          <rect x="{w*0.30}" y="{h*0.66}" width="{w*0.035}" height="{h*0.12}"/>
          <rect x="{w*0.40}" y="{h*0.66}" width="{w*0.035}" height="{h*0.12}"/>
          <rect x="{w*0.48}" y="{h*0.66}" width="{w*0.045}" height="{h*0.12}"/>
          <rect x="{w*0.58}" y="{h*0.66}" width="{w*0.035}" height="{h*0.12}"/>
          <rect x="{w*0.66}" y="{h*0.66}" width="{w*0.035}" height="{h*0.12}"/>
        </g>'''
    if scene == "garden":
        return f'''
        <ellipse cx="{w*0.48}" cy="{h*0.70}" rx="{w*0.34}" ry="{h*0.16}" fill="{light}" opacity="0.85"/>
        <path d="M{w*0.30} {h*0.70} Q {w*0.48} {h*0.52}, {w*0.66} {h*0.70}" fill="none" stroke="{accent}" stroke-width="8"/>
        <rect x="{w*0.62}" y="{h*0.48}" width="{w*0.12}" height="{h*0.12}" fill="{deep}"/>
        <polygon points="{w*0.58},{h*0.50} {w*0.68},{h*0.38} {w*0.78},{h*0.50}" fill="{accent}"/>
        <path d="M{w*0.08} {h*0.78} C {w*0.16} {h*0.50}, {w*0.22} {h*0.74}, {w*0.18} {h*0.90}" fill="none" stroke="{deep}" stroke-width="4"/>'''
    if scene == "lake":
        return f'''
        <path d="M0 {h*0.58} L{w*0.18} {h*0.48} L{w*0.32} {h*0.56} L{w*0.5} {h*0.42} L{w*0.7} {h*0.54} L{w} {h*0.46} V{h*0.62} H0 Z" fill="{deep}" opacity="0.55"/>
        <rect x="0" y="{h*0.60}" width="{w}" height="{h*0.40}" fill="{light}" opacity="0.55"/>
        <path d="M0 {h*0.70} H{w}" stroke="#ffffff" stroke-width="2" opacity="0.45"/>
        <path d="M0 {h*0.78} H{w}" stroke="#ffffff" stroke-width="2" opacity="0.3"/>
        <ellipse cx="{w*0.72}" cy="{h*0.30}" rx="{w*0.06}" ry="{h*0.09}" fill="{accent}" opacity="0.8"/>'''
    if scene == "river":
        return f'''
        <rect x="0" y="{h*0.62}" width="{w}" height="{h*0.38}" fill="{light}" opacity="0.7"/>
        <polygon points="{w*0.12},{h*0.66} {w*0.22},{h*0.28} {w*0.34},{h*0.66}" fill="{deep}"/>
        <polygon points="{w*0.36},{h*0.66} {w*0.50},{h*0.18} {w*0.66},{h*0.66}" fill="{deep}" opacity="0.85"/>
        <polygon points="{w*0.64},{h*0.66} {w*0.76},{h*0.34} {w*0.90},{h*0.66}" fill="{accent}" opacity="0.8"/>'''
    if scene == "coast":
        return f'''
        <rect x="0" y="{h*0.58}" width="{w}" height="{h*0.18}" fill="{light}" opacity="0.75"/>
        <path d="M0 {h*0.62} Q {w*0.25} {h*0.56}, {w*0.5} {h*0.62} T {w} {h*0.60} V{h*0.78} H0 Z" fill="{accent}" opacity="0.55"/>
        <path d="M0 {h*0.74} H{w} V{h} H0 Z" fill="{deep}"/>
        <circle cx="{w*(0.72-variant*0.08)}" cy="{h*0.28}" r="{h*0.08}" fill="{accent}"/>'''
    if scene == "town":
        roofs = []
        for i in range(6):
            x = w * (0.08 + i * 0.14)
            roofs.append(
                f'<polygon points="{x},{h*0.62} {x+w*0.06},{h*0.48} {x+w*0.12},{h*0.62}" fill="{accent}"/>'
                f'<rect x="{x+w*0.02}" y="{h*0.62}" width="{w*0.08}" height="{h*0.12}" fill="{deep}"/>'
            )
        return f'<rect x="0" y="{h*0.78}" width="{w}" height="{h*0.08}" fill="{light}" opacity="0.8"/>' + "".join(roofs)
    if scene == "grass":
        return f'''
        <path d="M0 {h*0.70} Q {w*0.5} {h*0.62}, {w} {h*0.72} V{h} H0 Z" fill="{light}"/>
        <path d="M0 {h*0.78} Q {w*0.5} {h*0.70}, {w} {h*0.80} V{h} H0 Z" fill="{deep}" opacity="0.8"/>
        <path d="M{w*0.62} {h*0.70} Q {w*0.70} {h*0.50}, {w*0.78} {h*0.70} Z" fill="{accent}"/>
        <path d="M{w*0.22} {h*0.74} Q {w*0.28} {h*0.58}, {w*0.34} {h*0.74} Z" fill="{accent}" opacity="0.8"/>'''
    if scene == "grotto":
        caves = []
        for i, cx in enumerate((0.28, 0.48, 0.68)):
            caves.append(
                f'<path d="M{w*cx-w*0.06} {h*0.70} Q {w*cx} {h*(0.42-i*0.02)}, {w*cx+w*0.06} {h*0.70} Z" fill="#1a140f"/>'
            )
        return f'<path d="M0 {h*0.42} H{w} V{h} H0 Z" fill="{deep}"/>' + "".join(caves) + f'<path d="M0 {h*0.78} H{w} V{h} H0 Z" fill="{accent}" opacity="0.35"/>'
    if scene == "waterfall":
        return f'''
        <path d="M0 {h*0.35} H{w*0.70} L{w*0.48} {h} H0 Z" fill="{deep}"/>
        <polygon points="{w*0.34},{h*0.28} {w*0.46},{h*0.28} {w*0.52},{h*0.92} {w*0.30},{h*0.92}" fill="{light}" opacity="0.9"/>
        <path d="M0 {h*0.86} H{w} V{h} H0 Z" fill="{accent}" opacity="0.45"/>'''
    if scene == "snow":
        return f'''
        <path d="M0 {h*0.62} L{w*0.2} {h*0.48} L{w*0.35} {h*0.60} L{w*0.5} {h*0.40} L{w*0.68} {h*0.58} L{w*0.82} {h*0.46} L{w} {h*0.64} V{h} H0 Z" fill="#ffffff" opacity="0.92"/>
        <rect x="{w*0.12}" y="{h*0.70}" width="{w*0.18}" height="{h*0.12}" fill="{light}"/>
        <rect x="{w*0.38}" y="{h*0.66}" width="{w*0.22}" height="{h*0.16}" fill="{accent}" opacity="0.85"/>
        <rect x="{w*0.66}" y="{h*0.72}" width="{w*0.16}" height="{h*0.10}" fill="{light}"/>'''
    if scene == "city":
        bars = []
        heights = (0.28, 0.42, 0.22, 0.50, 0.34, 0.26, 0.40)
        for i, bh in enumerate(heights):
            x = w * (0.08 + i * 0.12)
            bars.append(f'<rect x="{x}" y="{h*(0.72-bh)}" width="{w*0.08}" height="{h*bh}" fill="{deep if i % 2 == 0 else accent}" opacity="0.9"/>')
        return f'<rect x="0" y="{h*0.74}" width="{w}" height="{h*0.26}" fill="{light}" opacity="0.35"/>' + "".join(bars)
    # tomb
    warriors = []
    for i in range(8):
        x = w * (0.16 + i * 0.09)
        warriors.append(f'<rect x="{x}" y="{h*0.70}" width="{w*0.035}" height="{h*0.10}" fill="{accent}"/>')
    return f'<polygon points="{w*0.30},{h*0.66} {w*0.42},{h*0.42} {w*0.70},{h*0.42} {w*0.82},{h*0.66}" fill="{deep}"/>' + "".join(warriors)


def illustration(scene, w, h, variant, mark):
    sky, accent, light, deep = PALETTE.get(scene, PALETTE["mountain"])
    sunx = int(w * (0.16 + variant * 0.18))
    body = f'''<svg xmlns="{NS}" width="{w}" height="{h}" viewBox="0 0 {w} {h}" role="img">
      <defs>
        <linearGradient id="sk" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="{sky}"/>
          <stop offset="100%" stop-color="{light}"/>
        </linearGradient>
      </defs>
      <rect width="{w}" height="{h}" fill="url(#sk)"/>
      <circle cx="{sunx}" cy="{int(h*0.24)}" r="{int(min(w,h)*0.07)}" fill="{accent}" opacity="0.85"/>
      <ellipse cx="{w*0.5}" cy="{h*0.78}" rx="{w*0.28}" ry="{h*0.06}" fill="#ffffff" opacity="0.12"/>
      {_draw(scene, w, h, accent, light, deep, variant)}
      {_stamp(w, h, mark)}
    </svg>'''
    return body


def avatar(char, hue):
    return f'''<svg xmlns="{NS}" width="200" height="200" viewBox="0 0 200 200">
      <rect width="200" height="200" rx="100" fill="{hex_color(hue, 0.32, 0.32)}"/>
      <text x="100" y="122" text-anchor="middle" fill="#f6f1e7" font-size="84" font-family="STSong,SimSun,serif">{char}</text>
    </svg>'''


CATEGORIES = [
    ("历史古迹", "宫殿、陵寝、古城与祭坛", "史", 1),
    ("自然风光", "峰林、瀑布、丹霞与名山", "野", 2),
    ("园林建筑", "古典园林", "园", 3),
    ("城市地标", "城市中可步行到达的标志性区域", "标", 4),
    ("宗教文化", "石窟、寺院与宗教建筑", "寺", 5),
    ("海滨海岛", "海岸、海湾与步行岛屿", "海", 6),
]

# slug -> lng, lat, open_time, price, rating, visits, address
SPOT_META = {
    "gugong": (116.397128, 39.916527, "旺季 08:30-17:00，16:00 停止入馆；周一闭馆（法定节假日除外）", 60, 4.9, 865420, "北京市东城区景山前街4号"),
    "badaling": (116.016802, 40.356585, "旺季 06:30-16:30，淡季 07:30-16:00", 40, 4.8, 642110, "北京市延庆区八达岭特区"),
    "xihu": (120.148576, 30.242938, "环湖景区全天开放，收费景点另计", 0, 4.9, 920150, "浙江省杭州市西湖区龙井路1号"),
    "huangshan": (118.166496, 30.134136, "景区全天开放，索道约 06:30-16:30", 190, 4.8, 438900, "安徽省黄山市黄山区汤口镇"),
    "zhangjiajie": (110.479191, 29.327476, "07:00-18:00，核心景区索道另计", 225, 4.8, 389540, "湖南省张家界市武陵源区"),
    "jiuzhaigou": (103.918800, 33.260000, "旺季 08:00-17:00，实行限量预约", 160, 4.9, 456780, "四川省阿坝藏族羌族自治州九寨沟县"),
    "bingmayong": (109.273300, 34.385300, "08:30-18:00，16:30 停止入馆", 120, 4.8, 710200, "陕西省西安市临潼区秦陵北路"),
    "lijiang_guilin": (110.434000, 25.100000, "竹筏与游船按航班，约 08:00-16:30", 215, 4.7, 298600, "广西壮族自治区桂林市阳朔县漓江景区"),
    "budalagong": (91.117500, 29.655500, "旺季约 09:00 起分时段参观，须提前预约", 200, 4.9, 256800, "西藏自治区拉萨市城关区北京中路35号"),
    "gulangyu": (118.066800, 24.447800, "岛屿全天可步行，轮渡约 06:00-22:00", 35, 4.7, 334500, "福建省厦门市思明区鼓浪屿"),
    "taishan": (117.101000, 36.256000, "全天开放，索道约 06:30-17:00", 115, 4.8, 402330, "山东省泰安市泰山区红门路"),
    "lijiang_gucheng": (100.234000, 26.872000, "古城全天开放，部分院落另计", 0, 4.7, 512900, "云南省丽江市古城区"),
    "zhuozhengyuan": (120.629000, 31.324000, "07:30-17:30，16:30 停止入园", 90, 4.8, 287400, "江苏省苏州市姑苏区东北街178号"),
    "waitan": (121.490500, 31.241600, "外滩步道全天开放", 0, 4.8, 688200, "上海市黄浦区中山东一路"),
    "qufu_sankong": (116.986500, 35.596600, "08:00-17:20，孔庙孔府孔林联票", 80, 4.7, 198400, "山东省济宁市曲阜市神道路"),
    "emeishan": (103.336000, 29.525000, "全天开放，金顶索道约 07:00-18:00", 160, 4.8, 276500, "四川省乐山市峨眉山市名山南路"),
    "leshan_dafo": (103.773000, 29.544000, "07:30-18:30，17:30 停止购票", 80, 4.7, 241800, "四川省乐山市市中区凌云路"),
    "hongyadong": (106.578000, 29.562000, "全天开放，夜景约至 23:00", 0, 4.6, 455600, "重庆市渝中区嘉陵江滨江路88号"),
    "mogaoku": (94.808000, 40.041000, "08:00-18:00，洞窟分时段预约", 238, 4.9, 186500, "甘肃省酒泉市敦煌市莫高镇"),
    "yalongwan": (109.641000, 18.231000, "海湾全天开放", 0, 4.7, 302100, "海南省三亚市吉阳区亚龙湾"),
    "zhongyangdajie": (126.641000, 45.773000, "步行街全天开放", 0, 4.6, 268400, "黑龙江省哈尔滨市道里区中央大街"),
    "zhangye_danxia": (100.100000, 38.960000, "旺季 06:00-18:00，建议傍晚入园", 74, 4.8, 221300, "甘肃省张掖市临泽县倪家营镇"),
    "huangguoshu": (105.671000, 25.992000, "07:00-18:00", 160, 4.7, 254900, "贵州省安顺市镇宁布依族苗族自治县"),
    "pingyao": (112.176000, 37.201000, "古城全天，城墙与院落约 08:00-18:00", 125, 4.7, 233800, "山西省晋中市平遥县古城内"),
}

BANNER_TEXT = {
    "badaling": ("山脊上的长城", "八达岭北城，风比好汉坡更大"),
    "zhangjiajie": ("峰林与金鞭溪", "张家界适合把脚步放慢"),
    "jiuzhaigou": ("九寨沟的水会变色", "先预约，再把一天交给观光车"),
    "zhangye_danxia": ("张掖的彩色丘陵", "七彩丹霞，黄昏最合适"),
    "waitan": ("外滩的江风", "浦西的楼，和浦东的灯"),
}

ROUTES = [
    ("京华四日 · 皇城与长城", 4, 1280, "palace",
     "用四天把北京的中轴线和八达岭走完，按预约场次排，不赶日出团。",
     "适合第一次到北京。路线价格为交通与住宿的参考，不含景区大门票，门票请在本站按日期另约。\n第1天故宫中轴线；第2天东六宫；第3-4天八达岭往返。",
     [(1, "故宫", "中轴线与三大殿，预约上午场"),
      (2, "故宫", "东六宫与景山回望屋顶"),
      (3, "八达岭长城", "北城往返，预留下山时间"),
      (4, "八达岭长城", "南城补看，下午返城")]),
    ("江南烟雨五日", 5, 1680, "lake",
     "杭州西湖、上海外滩和苏州拙政园连成一条慢路线。",
     "第1-2天西湖环湖；第3天外滩，建议留到晚上；第4-5天苏州拙政园，并留半天给平江路。\n城际交通以高铁为主，演示参考价不含门票。",
     [(1, "杭州西湖", "白堤、苏堤与雷峰塔，按体力取舍"),
      (2, "杭州西湖", "灵隐、龙井一带，仍以西湖为落脚"),
      (3, "上海外滩", "白天看万国建筑，晚上看江对岸"),
      (4, "苏州拙政园", "上午入园，避开旅行团"),
      (5, "苏州拙政园", "补看园内西侧，下午返程")]),
    ("徽杭名山四日", 4, 1520, "mountain",
     "先把黄山的前后山走完，再降到杭州西湖收尾，体力和风景都有落差。",
     "黄山建议住山上一个晚上，才能等云海。第四天到杭州只安排环湖，不再加登山。",
     [(1, "黄山", "云谷索道上山，住光明顶或西海附近"),
      (2, "黄山", "日出与西海大峡谷"),
      (3, "黄山", "玉屏索道下山，汤口休整"),
      (4, "杭州西湖", "环湖步行，作为下山后的缓冲")]),
    ("湘黔山水四日", 4, 1460, "waterfall",
     "武陵源的峰林和黄果树的水雾，是西南两条完全不同的自然景观。",
     "张家界安排两天，不要把袁家界和金鞭溪挤在同一个上午。后两天转场安顺看瀑布。",
     [(1, "张家界国家森林公园", "金鞭溪徒步"),
      (2, "张家界国家森林公园", "袁家界与天子山"),
      (3, "黄果树瀑布", "大瀑布观景台"),
      (4, "黄果树瀑布", "天星桥，量力而行")]),
    ("川西秘境四日", 4, 1960, "lake",
     "九寨沟的水和峨眉山的云海放在一次川西行程里，中间需要留出交通。",
     "九寨沟必须按预约日进入。峨眉若只有一天，优先金顶，不要同时强求全山寺庙。",
     [(1, "九寨沟", "树正、诺日朗、五花海"),
      (2, "九寨沟", "长海、珍珠滩，按体力回头"),
      (3, "乐山大佛", "转场乐山，先看大佛"),
      (4, "峨眉山", "索道上金顶")]),
    ("陕甘丝路五日", 5, 2280, "tomb",
     "从兵马俑到张掖丹霞，再到敦煌莫高窟，把秦的地下军阵和丝路风光连起来。",
     "西安到敦煌距离远，演示行程默认含一段航空或过夜列车。莫高窟单独预约，不要与抵达同一小时叠在一起。",
     [(1, "秦始皇兵马俑", "一号坑、三号坑与铜车马"),
      (2, "张掖丹霞", "彩色丘陵，尽量赶在黄昏"),
      (3, "张掖丹霞", "清晨补看七彩一带，下午转场"),
      (4, "敦煌莫高窟", "数字展示中心与预约洞窟"),
      (5, "敦煌莫高窟", "鸣沙山方向自由活动，不重复进窟")]),
    ("山海四日 · 鼓浪屿与亚龙湾", 4, 1680, "coast",
     "厦门鼓浪屿和三亚亚龙湾，一段步行的岛，一段敞开的湾。",
     "前两天不要排太满，鼓浪屿适合步行。后两天把亚龙湾留在白天，傍晚看海就够了。",
     [(1, "厦门鼓浪屿", "轮渡上岛，日光岩"),
      (2, "厦门鼓浪屿", "内厝澳与环岛路"),
      (3, "三亚亚龙湾", "白天在湾里"),
      (4, "三亚亚龙湾", "清晨再走一次沙滩，下午返程")]),
    ("滇桂山水三日", 3, 1460, "town",
     "丽江古城负责走路，桂林漓江负责坐船，中间是一段航班或高铁。",
     "古城维护费按景区规则另行登记。漓江竹筏尽量排在上午。",
     [(1, "丽江古城", "四方街、木府"),
      (2, "丽江古城", "狮子山与安静的巷子"),
      (3, "桂林漓江", "阳朔段竹筏或游船")]),
    ("丝路与雪域四日", 4, 2680, "palace",
     "敦煌莫高窟和布达拉宫分属两段高原行程，适合已经有过高海拔经验的人。",
     "演示路线含敦煌与拉萨之间的航空。落地拉萨的第一天不进布达拉宫，只适应海拔。",
     [(1, "敦煌莫高窟", "数字展示中心与预约洞窟"),
      (2, "敦煌莫高窟", "补看展示，不重复进同一组洞窟"),
      (3, "布达拉宫", "抵拉萨，不安排登宫"),
      (4, "布达拉宫", "按预约时段参观")]),
]

USERS = [
    ("admin", "admin123", "系统管理员", "13800000000", "admin@shanhe.local", "ADMIN", 40),
    ("linwan", "user123", "林晓晚", "13800001001", "linwan@shanhe.local", "USER", 20),
    ("zhouan", "user123", "周予安", "13800001002", None, "USER", 16),
    ("chennan", "user123", "陈一楠", "13800001003", None, "USER", 13),
    ("suqing", "user123", "苏晚晴", "13800001004", None, "USER", 12),
    ("zhaobei", "user123", "赵北辰", "13800001005", None, "USER", 11),
    ("heman", "user123", "何曼", "13800001006", None, "USER", 9),
    ("liuchuan", "user123", "刘川", "13800001007", None, "USER", 8),
    ("tangguo", "user123", "唐果", "13800001008", None, "USER", 6),
    ("maoye", "user123", "毛野", "13800001009", None, "USER", 5),
    ("xueyao", "user123", "薛谣", "13800001010", None, "USER", 4),
    ("guqi", "user123", "顾七", "13800001011", None, "USER", 3),
    ("panxiao", "user123", "潘晓", "13800001012", None, "USER", 2),
    ("fengnian", "user123", "冯念", "13800001013", None, "USER", 1),
    ("jiangshu", "user123", "江疏", "13800001014", None, "USER", 0),
    ("luobai", "user123", "罗白", "13800001015", None, "USER", 0),
]

NOTES = [
    ("linwan", "杭州西湖", "APPROVED", "雨天的西湖比晴天更像一幅未干的画",
     "早上下了雨，白堤上的人比我想的少。水面没有那种明信片式的蓝，反而发灰，远处的雷峰塔像被橡皮擦过一遍。\n\n我从断桥走到平湖秋月，再折回锦带桥。雨衣的帽子一直滑下来，但这比晴天被人群推着走舒服。中午在湖滨随便吃了面，下午苏堤的风把云吹开了一条缝，湖面才忽然亮起来。\n\n如果只有一天，我仍然建议把走路放在船上：船会告诉你湖有多大，路会告诉你湖有多近。门票本身是免费的，游船另算，不用为了打卡把所有收费点买全。"),
    ("zhouan", "八达岭长城", "APPROVED", "八达岭不要只走到好汉坡",
     "好汉坡的牌坊前面永远在拍照，真正值得继续的是北城再往上的那几段。风会变大，城墙也更窄，但山的层次终于露出来。\n\n我坐缆车上去，步行下来。下行的时候膝盖比上行更累，所以不要把时间卡死。春秋的八达岭比夏天干净，冬天则要看积雪是否封路。\n\n门票不贵，贵的是来回的时间。从市区出发至少留出一整天，不要和故宫排在同一天。"),
    ("chennan", "故宫", "APPROVED", "故宫闭馆日前一天的中轴线",
     "周一闭馆，所以我把故宫放在周日。上午场的人已经很多，但中轴线一旦走起来，节奏就由自己掌握。太和殿前的空地比想象中更大，午门到神武门的距离也比地图看起来长。\n\n我没有进珍宝馆，把时间留给了东西六宫之间的夹道。那里的砖和窗比三大殿更接近人的尺度。出来时从景山后门往上看了一眼，整座宫殿的黄色屋顶才变成一张完整的图。\n\n预约按证件，不要临时换同行的人。讲解器值得租，比跟着扩音器走更安静。"),
    ("suqing", "九寨沟", "APPROVED", "九寨沟的水不是一种蓝",
     "五花海在中午偏绿，到了三点又透出一点紫。导游说是矿物质和光线，我更愿意相信是水底的树干在作怪。珍珠滩的水很浅，声音却很大。\n\n沟里全靠观光车。不要试图从树正走到长海，那不是散步距离。诺日朗用午餐人最多，自带一点干粮会从容。\n\n秋季是最挤的季节，预约成功才算数。我的订单日期比我想的早一天，幸好没有订错返程。"),
    ("zhaobei", "张家界国家森林公园", "APPROVED", "张家界金鞭溪适合把脚步放慢",
     "金鞭溪的水不深，路也平，峰林就立在溪的两边。这里不适合赶时间。我用了将近三个小时走完常用的那段，中间在溪石上坐了两次。\n\n下午上袁家界，风景突然从溪谷变成台地，人也会突然变多。百龙天梯省时间，但要单独买票。如果只能选一个，我选上午的溪和下午的台地，而不是两个都跑马。\n\n山上的雨说来就来，背包里的薄外套最后是全天最有用的东西。"),
    ("heman", "苏州拙政园", "APPROVED", "拙政园的白墙把光留住了",
     "进门以后先到远香堂，对面就是池子。苏州园林的好不在高，而在你每转一次身，画面的边界都被墙重新裁过。\n\n我在见山楼坐了一会儿。导游团过去之后，池子里的倒影才重新连上。园子不大，但不要用一小时把它走完，那会只剩下走廊。\n\n工作日上午最合适。联票里的博物馆可以用剩下的体力，不必强求。"),
    ("linwan", "厦门鼓浪屿", "APPROVED", "鼓浪屿绕开龙头路之后",
     "轮渡十五分钟就到了。龙头路很热闹，钢琴博物馆也值得看，但岛屿真正好走的是往内厝澳去的那些坡。房子的颜色开始变淡，还能听见操场的哨子。\n\n环岛一圈用不了一整天。日光岩可以上去，风大，鞋子要比漂亮更重要。岛上没有汽车，行李箱是错误的选择。\n\n轮渡票和景点票分开。如果不进收费点，只是走路和坐在海边，这一天已经完整。"),
    ("zhouan", "敦煌莫高窟", "APPROVED", "莫高窟的预约窟要提前看讲解",
     "数字展示中心的电影把壁画放大了，进窟以后反而要靠刚才的记忆。实体洞窟光线很暗，停留时间也短，没有提前了解就只剩下看一个洞口。\n\n讲解员的节奏固定，中间不能拍照。我把问题记在本子上，出来再问。敦煌的太阳很烈，从展示中心到窟区的摆渡车上就应该把水喝完。\n\n预约时段不要迟到。迟到不是排队的问题，而是这一组洞窟可能已经开始，你进不去。"),
    ("linwan", "平遥古城", "PENDING", "平遥南大街的晚上还没写完",
     "这篇还在整理。城墙上下来以后，我改走南大街后面的巷子，叫卖声被墙隔开了。日升昌只在门口看了一眼，没有再排队。\n\n想写清楚县衙前那棵树的光线，但照片还没挑。先提交给编辑看看结构是否成立。"),
    ("chennan", "黄山", "PENDING", "黄山看云海前请先读天气",
     "朋友临时约山上过夜，我劝他先看第二天的风。光明顶不是想来就来，索道也会因风停开。下山的末班比想象中早。\n\n这篇还缺我自己的上山记录，先作为草稿送审。如果通过，我会补上西海的时间表。"),
]

COMMENTS = [
    ("zhouan", "NOTE", "雨天的西湖比晴天更像一幅未干的画", "雨天的白堤确实更空。我上次走苏堤，伞都快被风收走。"),
    ("suqing", "NOTE", "雨天的西湖比晴天更像一幅未干的画", "赞同把船和路分开写，我之前一次买太全，反而累。"),
    ("heman", "NOTE", "八达岭不要只走到好汉坡", "北城的风比南城大一截，帽子要有绳子。"),
    ("linwan", "NOTE", "故宫闭馆日前一天的中轴线", "景山回头看屋顶那段，我下次也要留在最后。"),
    ("zhaobei", "NOTE", "九寨沟的水不是一种蓝", "五花海下午的颜色我至今没法用一种蓝描述。"),
    ("chennan", "NOTE", "张家界金鞭溪适合把脚步放慢", "金鞭溪的平路很友好，适合带父母，袁家界就不必了。"),
    ("tangguo", "NOTE", "拙政园的白墙把光留住了", "见山楼那一会儿最值得，人一散倒影就回来了。"),
    ("maoye", "NOTE", "鼓浪屿绕开龙头路之后", "内厝澳的坡很好走，龙头路的小吃可以点到为止。"),
    ("liuchuan", "SPOT", "故宫", "周日上午场已经要提前很久预约，中轴线的距离比地图长。"),
    ("suqing", "SPOT", "故宫", "讲解器比扩音器安静，东六宫的夹道值得慢慢看。"),
    ("heman", "SPOT", "杭州西湖", "清晨的断桥人少，游船建议放到下午风小的时候。"),
    ("zhaobei", "SPOT", "九寨沟", "观光车要跟上节奏，长海那一站不要迟到。"),
    ("jiangshu", "SPOT", "秦始皇兵马俑", "一号坑的军阵比照片更震撼，铜车马展厅别跳过。"),
    ("fengnian", "SPOT", "张家界国家森林公园", "金鞭溪可以走很久，百龙天梯的票记得单独买。"),
    ("panxiao", "SPOT", "丽江古城", "四方街晚上很热闹，想安静就往狮子山后面走。"),
    ("xueyao", "SPOT", "敦煌莫高窟", "数字电影先看再进窟，不然暗光里会错过细节。"),
    ("guqi", "SPOT", "苏州拙政园", "工作日上午进园，远香堂对面的池子最适合发呆。"),
    ("luobai", "SPOT", "八达岭长城", "从市区过去要留够一天，不建议和市区景点叠在一起。"),
    ("tangguo", "SPOT", "黄山", "山上比市区冷，六月我也穿了外套。索道尽量进出不走同一条。"),
    ("maoye", "SPOT", "布达拉宫", "落地当天不要安排参观，预约时段一定要守时。"),
]

FAVORITES = [
    ("linwan", "SPOT", "故宫"),
    ("linwan", "SPOT", "杭州西湖"),
    ("linwan", "SPOT", "九寨沟"),
    ("linwan", "SPOT", "丽江古城"),
    ("linwan", "ROUTE", "京华四日 · 皇城与长城"),
    ("linwan", "NOTE", "雨天的西湖比晴天更像一幅未干的画"),
    ("zhouan", "SPOT", "敦煌莫高窟"),
    ("zhouan", "SPOT", "八达岭长城"),
    ("chennan", "SPOT", "黄山"),
    ("suqing", "NOTE", "九寨沟的水不是一种蓝"),
    ("heman", "ROUTE", "江南烟雨五日"),
    ("zhaobei", "SPOT", "张家界国家森林公园"),
]

NEWS = [
    ("热门景区继续实行分时预约", "十一前后及周末，故宫、九寨沟、莫高窟等景区按日放票。请先注册并在门票页选择日期，订单以提交成功为准。",
     "为了避免现场排队，山河纪演示环境中的热门景点都要求先选日期和票种。\n\n同一证件在同一游玩日只保留一笔有效订单。取消订单会把库存退回，但请尽量提前操作。\n\n本公告为课程演示文案，实际出行请以景区官方公告为准。"),
    ("关于演示环境与票价的说明", "本站票价、开放时间和库存均为课程设计数据，不代表景区实时公示。",
     "山河纪是 Web 编程实践课程的综合项目，用于演示前后端分离、预约、游记审核和数据统计。\n\n景点介绍与图片来自随项目提供的媒体包，照片为 Wikimedia Commons 上的自由授权作品，作者和协议写在每张图下方，汇总见网站《素材署名》。一部分介绍视频仍使用 Wikimedia 文件地址。九寨沟等 14 个景点使用放在 /media/videos/ 的本地 MP4，来自 B 站公开片段，仅供课程展示，版权归原作者。\n\n请勿将演示订单用于真实出行。"),
    ("九寨沟秋季彩林观赏提示", "秋季是九寨沟最繁忙的季节，观光车班次会加密，仍建议按预约时段入沟。",
     "彩林通常出现在十月前后，具体变色进度每年不同。沟内温差大，薄外套比厚毛衣更灵活。\n\n诺日朗服务点午餐排队较长，可自带简单食物。不要离开栈道靠近钙化堤坝。"),
    ("故宫博物院周一闭馆提醒", "除法定节假日外，故宫博物院周一闭馆。请不要把行程死死卡在周一。",
     "如果行程里只有一个工作日可以安排故宫，请先确认那天不是周一。珍宝馆与钟表馆门票单独计算。\n\n演示环境里的成人票、学生票仅用于下单流程，不能作为入馆凭证。"),
    ("新路线「陕甘丝路五日」已发布", "兵马俑、张掖丹霞与莫高窟被串到同一条演示路线中，交通跨度较大，适合作为课程展示数据。",
     "这条路线的参考价不含大门票。莫高窟需要单独预约洞窟，丹霞的最佳光线多在傍晚。\n\n你可以从推荐路线页进入，再跳转到每个景点分别下单。"),
    ("文明参观倡议", "石窟内不拍照，长城上不攀爬未开放段落，园林里不踩草坪。",
     "评论和游记请使用文明用语。含有广告、人身攻击的内容会被管理员隐藏或驳回。\n\n演示账号仅供课程验收，请不要在游记中留下真实的证件号码或家庭住址。"),
]



def ts(days_ago, clock):
    return f"DATE_SUB(TIMESTAMP(CURDATE(), '{clock}'), INTERVAL {days_ago} DAY)"


def media_url(rel):
    return "/media/" + str(rel).lstrip("/")


def credit_text(item):
    if not item:
        return None
    note = (item.get("note") or "").strip()
    author = (item.get("author") or "").strip()
    license_name = (item.get("license") or "").strip()
    source = (item.get("source_page") or "").strip()
    prefix = (note + " · ") if note else ""
    full = prefix + " · ".join(part for part in (author, license_name, source) if part)
    short = prefix + " · ".join(part for part in (author, license_name) if part)
    text = full if len(full) <= 250 else short
    text = text.strip(" ·")
    if not text:
        return None
    return text[:250]


def main():
    manifest = json.loads((ROOT / "docs" / "media-manifest.json").read_text(encoding="utf-8"))
    pack_spots = manifest["spots"]
    cat_index = {name: i + 1 for i, (name, *_) in enumerate(CATEGORIES)}
    spot_index = {spot["name"]: i + 1 for i, spot in enumerate(pack_spots)}
    slug_of = {spot["name"]: spot["slug"] for spot in pack_spots}

    # 只清掉早期占位目录。videos/ 里是已入库的介绍视频，重新生成时必须保留。
    for folder in ("spots", "banners", "routes", "notes", "news"):
        stale = MEDIA / folder
        if stale.exists():
            shutil.rmtree(stale)
    (MEDIA / "avatars").mkdir(parents=True, exist_ok=True)
    (MEDIA / "images").mkdir(parents=True, exist_ok=True)
    (MEDIA / "videos").mkdir(parents=True, exist_ok=True)

    lines = [
        "-- 山河纪演示数据。票价与开放时间仅供课程展示，以景区公示为准。",
        "-- 图片与视频地址来自 docs/media-manifest.json。图片在 /media/images/，本地介绍视频在 /media/videos/。",
        "USE shanhe;",
        "SET NAMES utf8mb4;",
        "SET FOREIGN_KEY_CHECKS = 0;",
    ]

    hashes = {}
    for row in USERS:
        hashes.setdefault(row[1], bcrypt.hashpw(row[1].encode(), bcrypt.gensalt(rounds=10)).decode())

    lines.append("INSERT INTO `user` (username, password, nickname, phone, email, avatar, role, status, created_at, updated_at) VALUES")
    user_values = []
    for i, (username, password, nickname, phone, email, role, days) in enumerate(USERS, start=1):
        path = f"/media/avatars/{i}.svg"
        (MEDIA / "avatars" / f"{i}.svg").write_text(avatar(nickname[0], 20 + i * 18), encoding="utf-8")
        user_values.append(
            f"({q(username)}, {q(hashes[password])}, {q(nickname)}, {q(phone)}, {q(email)}, {q(path)}, {q(role)}, 1, {ts(days, '09:30:00')}, {ts(days, '09:30:00')})"
        )
    lines.append(",\n".join(user_values) + ";")

    lines.append("INSERT INTO spot_category (name, description, icon, sort_order, created_at) VALUES")
    lines.append(",\n".join(
        f"({q(n)}, {q(d)}, {q(icon)}, {sort}, {ts(30, '08:00:00')})"
        for n, d, icon, sort in CATEGORIES
    ) + ";")

    spot_rows = []
    image_rows = []
    ticket_rows = []
    ticket_seq = 1
    tickets_by_spot = {}
    for i, spot in enumerate(pack_spots, start=1):
        name = spot["name"]
        lng, lat, open_time, price, rating, visits, address = SPOT_META[spot["slug"]]
        if spot["category"] not in cat_index:
            raise SystemExit("manifest 分类未建表: " + spot["category"])
        cover = media_url(spot["thumb"])
        for v, image in enumerate(spot["images"], start=1):
            image_rows.append(
                f"({i}, {q(media_url(image['file']))}, {q(name + ' · ' + str(v))}, {q(credit_text(image))}, {v})"
            )
        video = spot.get("video") or {}
        video_url = (video.get("url") or "").strip() or None
        if video_url and video_url.startswith("/media/videos/"):
            local_video = MEDIA / video_url.removeprefix("/media/").lstrip("/")
            if not local_video.is_file():
                raise SystemExit("manifest 指向的本地视频不存在，拒绝生成空地址: " + str(local_video))
        summary = spot["intro"].strip()
        if len(summary) > 220:
            summary = summary[:218] + "…"
        detail = spot["intro"].strip() + "\n\n开放时间：" + open_time + "\n票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。"
        if video.get("note"):
            detail += "\n影像说明：" + video["note"].strip().rstrip("。") + "。"
        if price == 0:
            pair = [
                ("免票预约", 0, "开放区域免大门票，演示环境仍可生成预约订单", 20000),
                ("观光体验票", 60, "区间车、游船或讲解等体验项目，价格为演示值", 3000),
            ]
        else:
            half = round(price * 0.5, 2)
            stock_a, stock_b = 6000, 2500
            if name == "敦煌莫高窟":
                stock_a, stock_b = 800, 300
            elif name == "布达拉宫":
                stock_a, stock_b = 2000, 600
            pair = [
                ("成人票", price, "景区大门票，演示价格，以现场公示为准", stock_a),
                ("优惠票", half, "学生及符合条件的优惠人群，须核验证件", stock_b),
            ]
        # 与 SpotService.refreshPrice 相同：起价是在售票的最低价，不是成人票原价。
        from_price = min(item[1] for item in pair)
        spot_rows.append(
            "(" + ", ".join([
                str(cat_index[spot["category"]]), q(name), q(spot["province"]), q(spot["city"]), q(address),
                f"{lng:.6f}", f"{lat:.6f}", q(open_time), q(summary), q(detail),
                q(cover), q(video_url), q(credit_text(video) if video_url else None), f"{from_price:.2f}", f"{rating:.1f}", str(visits), "1",
                ts(28 - (i % 10), "10:00:00"), ts(2, "10:00:00"),
            ]) + ")"
        )
        tickets_by_spot[name] = []
        for t_name, t_price, t_desc, stock in pair:
            ticket_rows.append(
                f"({i}, {q(t_name)}, {t_price:.2f}, {q(t_desc)}, {stock}, 1, {ts(20, '11:00:00')})"
            )
            tickets_by_spot[name].append((ticket_seq, t_price, t_name))
            ticket_seq += 1

    lines.append("INSERT INTO scenic_spot (category_id, name, province, city, address, longitude, latitude, open_time, summary, detail, cover_url, video_url, video_credit, price_from, rating, visit_count, status, created_at, updated_at) VALUES")
    lines.append(",\n".join(spot_rows) + ";")
    lines.append("INSERT INTO spot_image (spot_id, url, caption, credit, sort_order) VALUES")
    lines.append(",\n".join(image_rows) + ";")
    lines.append("INSERT INTO ticket_type (spot_id, name, price, description, daily_stock, status, created_at) VALUES")
    lines.append(",\n".join(ticket_rows) + ";")

    route_rows = []
    route_spot_rows = []
    for i, (title, days, price, scene, summary, detail, stops) in enumerate(ROUTES, start=1):
        cover = media_url("images/" + slug_of[stops[0][1]] + "_thumb.webp")
        route_rows.append(
            f"({q(title)}, {days}, {q(cover)}, {q(summary)}, {q(detail)}, {price:.2f}, 1, {ts(18 - i, '09:00:00')}, {ts(3, '09:00:00')})"
        )
        for order, (day_no, spot_name, note) in enumerate(stops, start=1):
            route_spot_rows.append(
                f"({i}, {spot_index[spot_name]}, {day_no}, {order}, {q(note)})"
            )
    lines.append("INSERT INTO route (title, days, cover_url, summary, detail, price_from, status, created_at, updated_at) VALUES")
    lines.append(",\n".join(route_rows) + ";")
    lines.append("INSERT INTO route_spot (route_id, spot_id, day_no, sort_order, stay_note) VALUES")
    lines.append(",\n".join(route_spot_rows) + ";")

    user_id = {name: i for i, (name, *_) in enumerate(USERS, start=1)}
    note_id = {}
    note_rows = []
    like_rows = []
    like_plan = {
        "雨天的西湖比晴天更像一幅未干的画": ["zhouan", "suqing", "heman", "tangguo", "jiangshu"],
        "八达岭不要只走到好汉坡": ["linwan", "chennan", "liuchuan", "maoye"],
        "故宫闭馆日前一天的中轴线": ["linwan", "zhouan", "suqing", "zhaobei", "xueyao", "guqi"],
        "九寨沟的水不是一种蓝": ["zhaobei", "linwan", "heman", "panxiao"],
        "张家界金鞭溪适合把脚步放慢": ["chennan", "suqing", "fengnian"],
        "拙政园的白墙把光留住了": ["tangguo", "linwan", "luobai"],
        "鼓浪屿绕开龙头路之后": ["maoye", "zhouan", "heman", "jiangshu"],
        "莫高窟的预约窟要提前看讲解": ["linwan", "chennan", "xueyao", "guqi", "suqing"],
    }
    for i, (author, spot_name, status, title, content) in enumerate(NOTES, start=1):
        note_id[title] = i
        cover = media_url("images/" + slug_of[spot_name] + "_thumb.webp")
        likes = like_plan.get(title, [])
        days = 2 if status == "PENDING" else 6 + i
        note_rows.append("(" + ", ".join([
            str(user_id[author]), str(spot_index[spot_name]), q(title), q(cover), q(content),
            q(status), "NULL" if status != "REJECTED" else q("内容不完整"),
            str(len(likes)), str(80 + i * 17), ts(days, "15:20:00"), ts(1 if status == "PENDING" else days, "15:20:00"),
        ]) + ")")
        for username in likes:
            like_rows.append(f"({i}, {user_id[username]}, {ts(max(days - 1, 0), '18:00:00')})")
    lines.append("INSERT INTO travel_note (user_id, spot_id, title, cover_url, content, status, reject_reason, like_count, view_count, created_at, updated_at) VALUES")
    lines.append(",\n".join(note_rows) + ";")
    lines.append("INSERT INTO note_like (note_id, user_id, created_at) VALUES")
    lines.append(",\n".join(like_rows) + ";")

    comment_rows = []
    for i, (username, target_type, target, content) in enumerate(COMMENTS, start=1):
        target_pk = spot_index[target] if target_type == "SPOT" else note_id[target]
        comment_rows.append(
            f"({user_id[username]}, {q(target_type)}, {target_pk}, {q(content)}, 'VISIBLE', {ts(i % 9, '12:10:00')})"
        )
    lines.append("INSERT INTO comment (user_id, target_type, target_id, content, status, created_at) VALUES")
    lines.append(",\n".join(comment_rows) + ";")

    route_id = {title: i for i, (title, *_) in enumerate(ROUTES, start=1)}
    fav_rows = []
    for username, target_type, target in FAVORITES:
        if target_type == "SPOT":
            pk = spot_index[target]
        elif target_type == "ROUTE":
            pk = route_id[target]
        else:
            pk = note_id[target]
        fav_rows.append(f"({user_id[username]}, {q(target_type)}, {pk}, {ts(4, '20:00:00')})")
    lines.append("INSERT INTO favorite (user_id, target_type, target_id, created_at) VALUES")
    lines.append(",\n".join(fav_rows) + ";")

    news_rows = []
    for i, (title, summary, content) in enumerate(NEWS, start=1):
        cover = media_url(manifest["banners"][(i - 1) % len(manifest["banners"])]["file"])
        news_rows.append(
            f"({q(title)}, {q(cover)}, {q(summary)}, {q(content)}, 1, {ts(i, '08:30:00')}, {ts(i, '08:30:00')}, {ts(i, '08:30:00')})"
        )
    lines.append("INSERT INTO news (title, cover_url, summary, content, status, published_at, created_at, updated_at) VALUES")
    lines.append(",\n".join(news_rows) + ";")

    banner_rows = []
    for i, banner in enumerate(manifest["banners"], start=1):
        title, subtitle = BANNER_TEXT[banner["spot_slug"]]
        name = next(spot["name"] for spot in pack_spots if spot["slug"] == banner["spot_slug"])
        href = f"/spots/{spot_index[name]}"
        banner_rows.append(
            f"({q(title)}, {q(subtitle)}, {q(media_url(banner['file']))}, {q(href)}, {i}, 1, {ts(12, '08:00:00')})"
        )
    lines.append("INSERT INTO banner (title, subtitle, image_url, link_url, sort_order, status, created_at) VALUES")
    lines.append(",\n".join(banner_rows) + ";")

    # 订单：近 14 天分布，保证统计图有形状，并给 linwan 固定四笔。
    import random
    random.seed(20261022)
    weighted = (
        ["故宫"] * 8 + ["杭州西湖"] * 7 + ["九寨沟"] * 6 + ["秦始皇兵马俑"] * 6
        + ["张家界国家森林公园"] * 5 + ["八达岭长城"] * 5 + ["黄山"] * 4
        + ["桂林漓江"] * 4 + ["丽江古城"] * 3 + ["苏州拙政园"] * 3 + ["敦煌莫高窟"] * 3
        + ["泰山"] * 2 + ["平遥古城"] * 2 + ["布达拉宫"] * 2 + ["峨眉山"] * 2
        + ["黄果树瀑布"] * 2 + ["乐山大佛"] * 2 + ["张掖丹霞"] * 2 + ["曲阜三孔"] * 2
        + ["上海外滩"] * 2 + ["厦门鼓浪屿"] * 3 + ["哈尔滨中央大街"] * 2 + ["三亚亚龙湾"] * 2
        + ["重庆洪崖洞"] * 2
    )
    clocks = ["09:18:00", "10:42:00", "11:26:00", "14:05:00", "15:33:00", "16:48:00", "19:12:00"]
    normal_users = [row[0] for row in USERS if row[5] == "USER"]
    nick = {row[0]: row[2] for row in USERS}
    phone = {row[0]: row[3] for row in USERS}
    per_day = [2, 3, 2, 4, 3, 5, 4, 6, 3, 5, 7, 4, 6, 8]  # 13 天前 -> 今天
    order_rows = []
    seq = 1

    def add_order(username, spot_name, ticket_idx, qty, status, days_ago, visit_sql, clock):
        nonlocal seq
        ticket_id, price, _ = tickets_by_spot[spot_name][ticket_idx]
        total = price * qty
        order_rows.append("(" + ", ".join([
            q(f"SH{seq:08d}"),
            str(user_id[username]),
            str(spot_index[spot_name]),
            str(ticket_id),
            visit_sql,
            str(qty),
            f"{price:.2f}",
            f"{total:.2f}",
            q(nick[username]),
            q(phone[username]),
            q(status),
            "NULL",
            ts(days_ago, clock),
            ts(days_ago, clock),
        ]) + ")")
        seq += 1

    for days_ago, count in zip(range(13, -1, -1), per_day):
        for n in range(count):
            username = random.choice(normal_users)
            spot_name = random.choice(weighted)
            ticket_idx = 0 if random.random() < 0.75 else 1
            qty = random.randint(1, 3)
            roll = random.random()
            if days_ago <= 1 or roll < 0.62:
                status = "PENDING"
                visit_sql = f"DATE_ADD(CURDATE(), INTERVAL {random.randint(1, 18)} DAY)"
            elif roll < 0.88:
                status = "COMPLETED"
                visit_sql = f"DATE_SUB(CURDATE(), INTERVAL {random.randint(0, max(days_ago - 1, 0))} DAY)"
            else:
                status = "CANCELLED"
                visit_sql = f"DATE_ADD(CURDATE(), INTERVAL {random.randint(2, 12)} DAY)"
            add_order(username, spot_name, ticket_idx, qty, status, days_ago, visit_sql, clocks[n % len(clocks)])

    add_order("linwan", "故宫", 0, 2, "PENDING", 1, "DATE_ADD(CURDATE(), INTERVAL 5 DAY)", "09:40:00")
    add_order("linwan", "杭州西湖", 1, 1, "PENDING", 0, "DATE_ADD(CURDATE(), INTERVAL 3 DAY)", "11:15:00")
    add_order("linwan", "九寨沟", 0, 1, "COMPLETED", 6, "DATE_SUB(CURDATE(), INTERVAL 2 DAY)", "13:20:00")
    add_order("linwan", "敦煌莫高窟", 0, 1, "CANCELLED", 3, "DATE_ADD(CURDATE(), INTERVAL 9 DAY)", "17:05:00")

    lines.append("INSERT INTO booking_order (order_no, user_id, spot_id, ticket_type_id, visit_date, quantity, unit_price, total_amount, contact_name, contact_phone, status, remark, created_at, updated_at) VALUES")
    lines.append(",\n".join(order_rows) + ";")
    lines.append("SET FOREIGN_KEY_CHECKS = 1;")

    out = ROOT / "sql" / "data.sql"
    out.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"spots={len(pack_spots)} tickets={ticket_seq-1} orders={len(order_rows)} notes={len(NOTES)} -> {out}")


if __name__ == "__main__":
    main()
