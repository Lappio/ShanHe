-- 把 14 个景点的介绍视频改成本地文件。
-- 适用已经导入过旧版 sql/data.sql、不会重新初始化的数据库。
-- 新鲜部署直接导入 sql/data.sql 即可，不必再跑本脚本。
-- 执行：mysql --default-character-set=utf8mb4 -u root -p shanhe < sql/update_video_url.sql
-- 景点名与 sql/data.sql、docs/media-manifest.json 逐字一致。
-- 泰山是 UTF-8 U+6CF0 U+5C71，不要写成其它编码下的乱码。
USE shanhe;
SET NAMES utf8mb4;

START TRANSACTION;

UPDATE scenic_spot SET video_url = '/media/videos/jiuzhaigou.mp4',
  video_credit = 'B站 NoOne晓东 · 版权归原作者，仅课程展示 · https://www.bilibili.com/video/BV1MCUVB3EVF', updated_at = NOW()
WHERE name = '九寨沟';

UPDATE scenic_spot SET video_url = '/media/videos/lijiang_guilin.mp4',
  video_credit = 'B站 迈悦旅行家 · 版权归原作者，仅课程展示 · https://www.bilibili.com/video/BV1e7411M73E', updated_at = NOW()
WHERE name = '桂林漓江';

UPDATE scenic_spot SET video_url = '/media/videos/gulangyu.mp4',
  video_credit = 'B站 陈小羊看世界 · 版权归原作者，仅课程展示 · https://www.bilibili.com/video/BV17V4y1e7tU', updated_at = NOW()
WHERE name = '厦门鼓浪屿';

UPDATE scenic_spot SET video_url = '/media/videos/taishan.mp4',
  video_credit = 'B站 信标工坊 · 版权归原作者，仅课程展示 · https://www.bilibili.com/video/BV1dH28YPEtt', updated_at = NOW()
WHERE name = '泰山';

UPDATE scenic_spot SET video_url = '/media/videos/zhuozhengyuan.mp4',
  video_credit = 'B站 楚狂-漫游中国 · 版权归原作者，仅课程展示 · https://www.bilibili.com/video/BV1yw411872w', updated_at = NOW()
WHERE name = '苏州拙政园';

UPDATE scenic_spot SET video_url = '/media/videos/qufu_sankong.mp4',
  video_credit = 'B站 遠漂記 · 版权归原作者，仅课程展示 · https://www.bilibili.com/video/BV1P54y1S7fh', updated_at = NOW()
WHERE name = '曲阜三孔';

UPDATE scenic_spot SET video_url = '/media/videos/emeishan.mp4',
  video_credit = 'B站 CC航拍 · 版权归原作者，仅课程展示 · https://www.bilibili.com/video/BV1BV411K71r', updated_at = NOW()
WHERE name = '峨眉山';

UPDATE scenic_spot SET video_url = '/media/videos/leshan_dafo.mp4',
  video_credit = 'B站 著名电影电视剧观众w · 版权归原作者，仅课程展示 · https://www.bilibili.com/video/BV1BV4y1M7Qa', updated_at = NOW()
WHERE name = '乐山大佛';

UPDATE scenic_spot SET video_url = '/media/videos/hongyadong.mp4',
  video_credit = 'B站 躺下等存款自己增加 · 版权归原作者，仅课程展示 · https://www.bilibili.com/video/BV1DCo1Y8EMw', updated_at = NOW()
WHERE name = '重庆洪崖洞';

UPDATE scenic_spot SET video_url = '/media/videos/yalongwan.mp4',
  video_credit = 'B站 渣渣辉摄影 · 版权归原作者，仅课程展示 · https://www.bilibili.com/video/BV1iRWNzWERq', updated_at = NOW()
WHERE name = '三亚亚龙湾';

UPDATE scenic_spot SET video_url = '/media/videos/zhangye_danxia.mp4',
  video_credit = 'B站 ChinaEX123 · 版权归原作者，仅课程展示 · https://www.bilibili.com/video/BV1oT4y1L7FZ', updated_at = NOW()
WHERE name = '张掖丹霞';

UPDATE scenic_spot SET video_url = '/media/videos/pingyao.mp4',
  video_credit = 'B站 月翼之一 · 版权归原作者，仅课程展示 · https://www.bilibili.com/video/BV1rp4y147KH', updated_at = NOW()
WHERE name = '平遥古城';

UPDATE scenic_spot SET video_url = '/media/videos/badaling.mp4',
  video_credit = 'B站 潇庭木下 · 版权归原作者，仅课程展示 · https://www.bilibili.com/video/BV1y4411y7Ji', updated_at = NOW()
WHERE name = '八达岭长城';

UPDATE scenic_spot SET video_url = '/media/videos/huangguoshu.mp4',
  video_credit = 'B站 DANC弹壳 · 版权归原作者，仅课程展示 · https://www.bilibili.com/video/BV1UW4y1b7w9', updated_at = NOW()
WHERE name = '黄果树瀑布';

COMMIT;

-- 应返回 14 行。若少了泰山，先确认客户端字符集是 utf8mb4。
SELECT name, video_url, video_credit FROM scenic_spot
WHERE video_url LIKE '/media/videos/%' ORDER BY id;
