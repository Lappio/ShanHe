-- 把介绍视频改成外链。新鲜部署导入 sql/data.sql 即可，不必再跑本脚本。
-- 若库里还是上一版写进去的本地文件地址，执行本脚本即可改掉。
-- 执行：mysql --default-character-set=utf8mb4 -u root -p shanhe < sql/update_video_url.sql
-- 景点名与 sql/data.sql 逐字一致。泰山是 UTF-8 U+6CF0 U+5C71。
USE shanhe;
SET NAMES utf8mb4;

START TRANSACTION;

UPDATE scenic_spot SET video_url = 'https://archive.org/download/the-tour-of-jiuzhaigou-2000-dvd/TheTourOfJiuzhaigou%282000%29DVD.mp4#t=298',
  video_credit = 'archive.org · Archive.org 上传者 · 版权归原作者，仅课程展示 · https://archive.org/details/the-tour-of-jiuzhaigou-2000-dvd', updated_at = NOW()
WHERE name = '九寨沟';

UPDATE scenic_spot SET video_url = 'https://archive.org/download/SEG234GreatGetawaysTamaraLynnScottGuilinLiRiverCruise/234GuilinLiRiverCruise.mp4#t=80',
  video_credit = 'archive.org · Tamara Lynn Scott / Great Getaways · 版权归原作者，仅课程展示 · https://archive.org/details/SEG234GreatGetawaysTamaraLynnScottGuilinLiRiverCruise', updated_at = NOW()
WHERE name = '桂林漓江';

UPDATE scenic_spot SET video_url = 'https://archive.org/download/BiliBili-BV1L8411278C_p1-C7L1VB/BV1L8411278C_p1.ia.mp4#t=940',
  video_credit = 'archive.org · B 站 UP 主（画面水印：王师傅和小毛毛） · 版权归原作者，仅课程展示 · https://archive.org/details/BiliBili-BV1L8411278C_p1-C7L1VB', updated_at = NOW()
WHERE name = '泰山';

UPDATE scenic_spot SET video_url = 'https://archive.org/download/AroundTheWorldIn80Gardens6ChinaAndJapan/AroundTheWorldIn80Gardens6.mp4#t=75',
  video_credit = 'archive.org · BBC / Monty Don · 版权归原作者，仅课程展示 · https://archive.org/details/AroundTheWorldIn80Gardens6ChinaAndJapan', updated_at = NOW()
WHERE name = '苏州拙政园';

UPDATE scenic_spot SET video_url = 'https://archive.org/download/ThisGiantBuddhaWasBuiltToProtectPassingBoats/This%20Giant%20Buddha%20Was%20Built%20to%20Protect%20Passing%20Boats%20%282%29.mp4#t=30',
  video_credit = 'archive.org · Smithsonian Channel · 版权归原作者，仅课程展示 · https://archive.org/details/ThisGiantBuddhaWasBuiltToProtectPassingBoats', updated_at = NOW()
WHERE name = '乐山大佛';

UPDATE scenic_spot SET video_url = 'https://archive.org/download/youtube-uEocv4CWEFE/uEocv4CWEFE.mp4#t=12',
  video_credit = 'archive.org · YouTube 上传者（Archive.org 镜像） · 版权归原作者，仅课程展示 · https://archive.org/details/youtube-uEocv4CWEFE', updated_at = NOW()
WHERE name = '张掖丹霞';

UPDATE scenic_spot SET video_url = 'https://archive.org/download/BiliBili-BV15W411P7GY/BV15W411P7GY.mp4#t=207',
  video_credit = 'archive.org · B 站 UP 主 晓丹 · 版权归原作者，仅课程展示 · https://archive.org/details/BiliBili-BV15W411P7GY', updated_at = NOW()
WHERE name = '厦门鼓浪屿';

UPDATE scenic_spot SET video_url = 'https://archive.org/download/BiliBili-BV16t411w7HJ_p1-JH8VB/BV16t411w7HJ_p1.mp4#t=20',
  video_credit = 'archive.org · B 站 UP 主（Archive.org 镜像） · 版权归原作者，仅课程展示 · https://archive.org/details/BiliBili-BV16t411w7HJ_p1-JH8VB', updated_at = NOW()
WHERE name = '三亚亚龙湾';

UPDATE scenic_spot SET video_url = 'https://archive.org/download/4kchongqingaerialphotography/%E3%80%904K%E3%80%91%E9%87%8D%E5%BA%86%20Chongqing%20Aerial%20photography%20%E6%8D%A2%E4%B8%AA%E8%A7%92%E5%BA%A6%E7%9C%8B%E9%87%8D%E5%BA%86.mp4#t=12',
  video_credit = 'archive.org · 彭俊（片尾署名） · 版权归原作者，仅课程展示 · https://archive.org/details/4kchongqingaerialphotography', updated_at = NOW()
WHERE name = '重庆洪崖洞';

UPDATE scenic_spot SET video_url = NULL, video_credit = NULL, updated_at = NOW()
WHERE name = '峨眉山';

UPDATE scenic_spot SET video_url = NULL, video_credit = NULL, updated_at = NOW()
WHERE name = '曲阜三孔';

UPDATE scenic_spot SET video_url = NULL, video_credit = NULL, updated_at = NOW()
WHERE name = '平遥古城';

UPDATE scenic_spot SET video_url = 'https://upload.wikimedia.org/wikipedia/commons/7/7c/Flying_the_Drone_around_the_Great_Wall_of_China_near_Jinshan_Ridge.webm',
  video_credit = 'Commons 上无八达岭段的自由授权视频；此为金山岭长城航拍，可作长城通用介绍视频 · Johnny Xmas · CC BY 3.0 · https://commons.wikimedia.org/wiki/File:Flying_the_Drone_around_the_Great_Wall_of_China_near_Jinshan_Ridge.webm', updated_at = NOW()
WHERE name = '八达岭长城';

UPDATE scenic_spot SET video_url = 'https://upload.wikimedia.org/wikipedia/commons/4/40/2019%E5%B9%B41%E6%9C%883%E6%97%A5_%E5%BC%A0%E5%AE%B6%E7%95%8C%E9%9B%AA%E5%90%8E%E9%9B%BE%E5%87%87%E4%BA%91%E6%B5%B7%E6%9C%A6%E8%83%A7%E5%A6%82%E4%BB%99%E5%A2%83.webm',
  video_credit = '片头为张家界，后半段为黄果树瀑布（共用） · 中国新闻网 · CC BY 3.0 · https://commons.wikimedia.org/wiki/File:2019%E5%B9%B41%E6%9C%883%E6%97%A5_%E5%BC%A0%E5%AE%B6%E7%95%8C%E9%9B%AA%E5%90%8E%E9%9B%BE%E5%87%87%E4%BA%91%E6%B5%B7%E6%9C%A6%E8%83%A7%E5%A6%82%E4%BB%99%E5%A2%83.webm', updated_at = NOW()
WHERE name = '黄果树瀑布';

COMMIT;

-- 9 条 Archive.org（地址带 #t=）、2 条 Wikimedia、3 条空地址。
SELECT name, video_url, video_credit FROM scenic_spot
WHERE name IN ('九寨沟', '桂林漓江', '泰山', '苏州拙政园', '乐山大佛', '张掖丹霞', '厦门鼓浪屿', '三亚亚龙湾', '重庆洪崖洞', '峨眉山', '曲阜三孔', '平遥古城', '八达岭长城', '黄果树瀑布')
ORDER BY id;
