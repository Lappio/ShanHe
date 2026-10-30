-- 山河纪演示数据。票价与开放时间仅供课程展示，以景区公示为准。
-- 图片与视频地址来自 docs/media-manifest.json，文件在 /media/images/。
USE shanhe;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
INSERT INTO `user` (username, password, nickname, phone, email, avatar, role, status, created_at, updated_at) VALUES
('admin', '$2b$10$aj19hfkpLyAvqHzm6VZpyO6//sr0cSLxlPJmFyrOJMFRHURGfC61K', '系统管理员', '13800000000', 'admin@shanhe.local', '/media/avatars/1.svg', 'ADMIN', 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 40 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 40 DAY)),
('linwan', '$2b$10$FXXuKRUdmUk.elMRiNWHpu/PWVQWUcyKxbe7oW2IGlQ9ni2OVl4am', '林晓晚', '13800001001', 'linwan@shanhe.local', '/media/avatars/2.svg', 'USER', 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 20 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 20 DAY)),
('zhouan', '$2b$10$FXXuKRUdmUk.elMRiNWHpu/PWVQWUcyKxbe7oW2IGlQ9ni2OVl4am', '周予安', '13800001002', NULL, '/media/avatars/3.svg', 'USER', 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 16 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 16 DAY)),
('chennan', '$2b$10$FXXuKRUdmUk.elMRiNWHpu/PWVQWUcyKxbe7oW2IGlQ9ni2OVl4am', '陈一楠', '13800001003', NULL, '/media/avatars/4.svg', 'USER', 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 13 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 13 DAY)),
('suqing', '$2b$10$FXXuKRUdmUk.elMRiNWHpu/PWVQWUcyKxbe7oW2IGlQ9ni2OVl4am', '苏晚晴', '13800001004', NULL, '/media/avatars/5.svg', 'USER', 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 12 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 12 DAY)),
('zhaobei', '$2b$10$FXXuKRUdmUk.elMRiNWHpu/PWVQWUcyKxbe7oW2IGlQ9ni2OVl4am', '赵北辰', '13800001005', NULL, '/media/avatars/6.svg', 'USER', 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 11 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 11 DAY)),
('heman', '$2b$10$FXXuKRUdmUk.elMRiNWHpu/PWVQWUcyKxbe7oW2IGlQ9ni2OVl4am', '何曼', '13800001006', NULL, '/media/avatars/7.svg', 'USER', 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 9 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 9 DAY)),
('liuchuan', '$2b$10$FXXuKRUdmUk.elMRiNWHpu/PWVQWUcyKxbe7oW2IGlQ9ni2OVl4am', '刘川', '13800001007', NULL, '/media/avatars/8.svg', 'USER', 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 8 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 8 DAY)),
('tangguo', '$2b$10$FXXuKRUdmUk.elMRiNWHpu/PWVQWUcyKxbe7oW2IGlQ9ni2OVl4am', '唐果', '13800001008', NULL, '/media/avatars/9.svg', 'USER', 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 6 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 6 DAY)),
('maoye', '$2b$10$FXXuKRUdmUk.elMRiNWHpu/PWVQWUcyKxbe7oW2IGlQ9ni2OVl4am', '毛野', '13800001009', NULL, '/media/avatars/10.svg', 'USER', 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 5 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 5 DAY)),
('xueyao', '$2b$10$FXXuKRUdmUk.elMRiNWHpu/PWVQWUcyKxbe7oW2IGlQ9ni2OVl4am', '薛谣', '13800001010', NULL, '/media/avatars/11.svg', 'USER', 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 4 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 4 DAY)),
('guqi', '$2b$10$FXXuKRUdmUk.elMRiNWHpu/PWVQWUcyKxbe7oW2IGlQ9ni2OVl4am', '顾七', '13800001011', NULL, '/media/avatars/12.svg', 'USER', 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 3 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 3 DAY)),
('panxiao', '$2b$10$FXXuKRUdmUk.elMRiNWHpu/PWVQWUcyKxbe7oW2IGlQ9ni2OVl4am', '潘晓', '13800001012', NULL, '/media/avatars/13.svg', 'USER', 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 2 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 2 DAY)),
('fengnian', '$2b$10$FXXuKRUdmUk.elMRiNWHpu/PWVQWUcyKxbe7oW2IGlQ9ni2OVl4am', '冯念', '13800001013', NULL, '/media/avatars/14.svg', 'USER', 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 1 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 1 DAY)),
('jiangshu', '$2b$10$FXXuKRUdmUk.elMRiNWHpu/PWVQWUcyKxbe7oW2IGlQ9ni2OVl4am', '江疏', '13800001014', NULL, '/media/avatars/15.svg', 'USER', 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 0 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 0 DAY)),
('luobai', '$2b$10$FXXuKRUdmUk.elMRiNWHpu/PWVQWUcyKxbe7oW2IGlQ9ni2OVl4am', '罗白', '13800001015', NULL, '/media/avatars/16.svg', 'USER', 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 0 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:30:00'), INTERVAL 0 DAY));
INSERT INTO spot_category (name, description, icon, sort_order, created_at) VALUES
('历史古迹', '宫殿、陵寝、古城与祭坛', '史', 1, DATE_SUB(TIMESTAMP(CURDATE(), '08:00:00'), INTERVAL 30 DAY)),
('自然风光', '峰林、瀑布、丹霞与名山', '野', 2, DATE_SUB(TIMESTAMP(CURDATE(), '08:00:00'), INTERVAL 30 DAY)),
('园林建筑', '古典园林', '园', 3, DATE_SUB(TIMESTAMP(CURDATE(), '08:00:00'), INTERVAL 30 DAY)),
('城市地标', '城市中可步行到达的标志性区域', '标', 4, DATE_SUB(TIMESTAMP(CURDATE(), '08:00:00'), INTERVAL 30 DAY)),
('宗教文化', '石窟、寺院与宗教建筑', '寺', 5, DATE_SUB(TIMESTAMP(CURDATE(), '08:00:00'), INTERVAL 30 DAY)),
('海滨海岛', '海岸、海湾与步行岛屿', '海', 6, DATE_SUB(TIMESTAMP(CURDATE(), '08:00:00'), INTERVAL 30 DAY));
-- price_from 取该景点在售票的最低价，与保存票种时的重算规则相同。
INSERT INTO scenic_spot (category_id, name, province, city, address, longitude, latitude, open_time, summary, detail, cover_url, video_url, video_credit, price_from, rating, visit_count, status, created_at, updated_at) VALUES
(1, '故宫', '北京市', '北京市', '北京市东城区景山前街4号', 116.397128, 39.916527, '旺季 08:30-17:00，16:00 停止入馆；周一闭馆（法定节假日除外）', '故宫位于北京城中轴线的中心，旧称紫禁城，是明清两代的皇家宫殿，也是世界上现存规模最大、保存最为完整的木质结构古建筑群之一。宫城四面环有高墙与护城河，以太和殿、中和殿、保和殿为核心的外朝庄严宏伟，内廷宫院则精巧幽深。如今这里作为故宫博物院对公众开放，收藏有大量珍贵文物，并已列入世界文化遗产名录，是了解中国古代宫廷建筑与历史文化的首选之地。', '故宫位于北京城中轴线的中心，旧称紫禁城，是明清两代的皇家宫殿，也是世界上现存规模最大、保存最为完整的木质结构古建筑群之一。宫城四面环有高墙与护城河，以太和殿、中和殿、保和殿为核心的外朝庄严宏伟，内廷宫院则精巧幽深。如今这里作为故宫博物院对公众开放，收藏有大量珍贵文物，并已列入世界文化遗产名录，是了解中国古代宫廷建筑与历史文化的首选之地。

开放时间：旺季 08:30-17:00，16:00 停止入馆；周一闭馆（法定节假日除外）
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。', '/media/images/gugong_thumb.webp', 'https://upload.wikimedia.org/wikipedia/commons/7/71/Verbotene_Stadt.ogv', 'Nicor · CC BY-SA 3.0 · https://commons.wikimedia.org/wiki/File:Verbotene_Stadt.ogv', 30.00, 4.9, 865420, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 27 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(1, '八达岭长城', '北京市', '北京市', '北京市延庆区八达岭特区', 116.016802, 40.356585, '旺季 06:30-16:30，淡季 07:30-16:00', '八达岭长城位于北京市延庆区，是明长城中保存最好、最具代表性的段落之一，也是最早向游客开放的长城景区。城墙依山势蜿蜒于燕山山脉之间，敌楼、关城错落分布，地势险要，自古为拱卫京师的重要关隘。登上城墙远眺，群山起伏，春有山花、秋有红叶，四季景色各异。长城作为世界文化遗产，八达岭段接待过众多中外访客，被视为中华民族的重要象征。', '八达岭长城位于北京市延庆区，是明长城中保存最好、最具代表性的段落之一，也是最早向游客开放的长城景区。城墙依山势蜿蜒于燕山山脉之间，敌楼、关城错落分布，地势险要，自古为拱卫京师的重要关隘。登上城墙远眺，群山起伏，春有山花、秋有红叶，四季景色各异。长城作为世界文化遗产，八达岭段接待过众多中外访客，被视为中华民族的重要象征。

开放时间：旺季 06:30-16:30，淡季 07:30-16:00
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。
影像说明：Commons 上无八达岭段的自由授权视频；此为金山岭长城航拍，可作长城通用介绍视频。', '/media/images/badaling_thumb.webp', 'https://upload.wikimedia.org/wikipedia/commons/7/7c/Flying_the_Drone_around_the_Great_Wall_of_China_near_Jinshan_Ridge.webm', 'Commons 上无八达岭段的自由授权视频；此为金山岭长城航拍，可作长城通用介绍视频 · Johnny Xmas · CC BY 3.0 · https://commons.wikimedia.org/wiki/File:Flying_the_Drone_around_the_Great_Wall_of_China_near_Jinshan_Ridge.webm', 20.00, 4.8, 642110, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 26 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(2, '杭州西湖', '浙江省', '杭州市', '浙江省杭州市西湖区龙井路1号', 120.148576, 30.242938, '环湖景区全天开放，收费景点另计', '杭州西湖位于浙江省杭州市西部，三面环山、一面临城，以秀丽的湖光山色和深厚的人文积淀闻名天下。苏堤、白堤横卧湖上，断桥、雷峰塔、三潭印月等景点散布四周，留下了白居易、苏轼等文人的诗篇与传说。“西湖十景”四季各有韵味，春看桃柳、夏赏荷花、秋闻桂香、冬观残雪。杭州西湖文化景观已列入世界遗产名录，被誉为“人间天堂”的代表。', '杭州西湖位于浙江省杭州市西部，三面环山、一面临城，以秀丽的湖光山色和深厚的人文积淀闻名天下。苏堤、白堤横卧湖上，断桥、雷峰塔、三潭印月等景点散布四周，留下了白居易、苏轼等文人的诗篇与传说。“西湖十景”四季各有韵味，春看桃柳、夏赏荷花、秋闻桂香、冬观残雪。杭州西湖文化景观已列入世界遗产名录，被誉为“人间天堂”的代表。

开放时间：环湖景区全天开放，收费景点另计
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。', '/media/images/xihu_thumb.webp', 'https://upload.wikimedia.org/wikipedia/commons/8/82/Walking_China%2C_Hang_Zhou%2C_Exploring_the_beautiful_West_Lake_in_Hangzhou_by_Boat.webm', 'Walking China · CC BY 3.0 · https://commons.wikimedia.org/wiki/File:Walking_China,_Hang_Zhou,_Exploring_the_beautiful_West_Lake_in_Hangzhou_by_Boat.webm', 0.00, 4.9, 920150, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 25 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(2, '黄山', '安徽省', '黄山市', '安徽省黄山市黄山区汤口镇', 118.166496, 30.134136, '景区全天开放，索道约 06:30-16:30', '黄山位于安徽省南部黄山市，是中国最著名的山岳风景区之一，素以奇松、怪石、云海、温泉、冬雪“五绝”著称。花岗岩峰林拔地而起，莲花峰、光明顶、天都峰等主峰雄奇险峻，迎客松更是黄山的标志。云雾在峰谷间翻涌，日出与晚霞变幻莫测，自古吸引无数文人画家前来。黄山已被列入世界文化与自然双重遗产名录，并有“五岳归来不看山，黄山归来不看岳”的美誉。', '黄山位于安徽省南部黄山市，是中国最著名的山岳风景区之一，素以奇松、怪石、云海、温泉、冬雪“五绝”著称。花岗岩峰林拔地而起，莲花峰、光明顶、天都峰等主峰雄奇险峻，迎客松更是黄山的标志。云雾在峰谷间翻涌，日出与晚霞变幻莫测，自古吸引无数文人画家前来。黄山已被列入世界文化与自然双重遗产名录，并有“五岳归来不看山，黄山归来不看岳”的美誉。

开放时间：景区全天开放，索道约 06:30-16:30
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。', '/media/images/huangshan_thumb.webp', 'https://upload.wikimedia.org/wikipedia/commons/c/c7/Hu%C3%A1ngsh%C4%81n.ogv', 'Thomas LOMBARD · CC BY-SA 3.0 · https://commons.wikimedia.org/wiki/File:Hu%C3%A1ngsh%C4%81n.ogv', 95.00, 4.8, 438900, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 24 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(2, '张家界国家森林公园', '湖南省', '张家界市', '湖南省张家界市武陵源区', 110.479191, 29.327476, '07:00-18:00，核心景区索道另计', '张家界国家森林公园位于湖南省张家界市武陵源区，是中国第一个国家森林公园，也是武陵源风景名胜区的核心组成部分。这里以独特的石英砂岩峰林地貌闻名，成百上千座石柱拔地而起，峰壁陡峭、形态各异，山间林木葱郁、云雾缭绕。袁家界、金鞭溪、黄石寨等景区各具特色，峰林景观宛如仙境。武陵源作为世界自然遗产，以其奇特的地貌和良好的生态吸引着世界各地的游客。', '张家界国家森林公园位于湖南省张家界市武陵源区，是中国第一个国家森林公园，也是武陵源风景名胜区的核心组成部分。这里以独特的石英砂岩峰林地貌闻名，成百上千座石柱拔地而起，峰壁陡峭、形态各异，山间林木葱郁、云雾缭绕。袁家界、金鞭溪、黄石寨等景区各具特色，峰林景观宛如仙境。武陵源作为世界自然遗产，以其奇特的地貌和良好的生态吸引着世界各地的游客。

开放时间：07:00-18:00，核心景区索道另计
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。
影像说明：中新网短讯，前半段为张家界武陵源雪后云海。', '/media/images/zhangjiajie_thumb.webp', 'https://upload.wikimedia.org/wikipedia/commons/4/40/2019%E5%B9%B41%E6%9C%883%E6%97%A5_%E5%BC%A0%E5%AE%B6%E7%95%8C%E9%9B%AA%E5%90%8E%E9%9B%BE%E5%87%87%E4%BA%91%E6%B5%B7%E6%9C%A6%E8%83%A7%E5%A6%82%E4%BB%99%E5%A2%83.webm', '中新网短讯，前半段为张家界武陵源雪后云海 · 中国新闻网 · CC BY 3.0 · https://commons.wikimedia.org/wiki/File:2019%E5%B9%B41%E6%9C%883%E6%97%A5_%E5%BC%A0%E5%AE%B6%E7%95%8C%E9%9B%AA%E5%90%8E%E9%9B%BE%E5%87%87%E4%BA%91%E6%B5%B7%E6%9C%A6%E8%83%A7%E5%A6%82%E4%BB%99%E5%A2%83.webm', 112.50, 4.8, 389540, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 23 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(2, '九寨沟', '四川省', '阿坝藏族羌族自治州', '四川省阿坝藏族羌族自治州九寨沟县', 103.918800, 33.260000, '旺季 08:00-17:00，实行限量预约', '九寨沟位于四川省阿坝藏族羌族自治州九寨沟县，因沟内分布有多个藏族村寨而得名。景区以翠海、叠瀑、彩林、雪峰和藏族风情为主要特色，湖泊由钙华沉积形成，湖水清澈透亮，在阳光下呈现蓝、绿、黄等斑斓色彩，被称为“海子”。五花海、长海、诺日朗瀑布等景点闻名遐迩，秋季彩林层叠时尤为绚丽。九寨沟是世界自然遗产，也是国家级自然保护区，有“童话世界”之称。', '九寨沟位于四川省阿坝藏族羌族自治州九寨沟县，因沟内分布有多个藏族村寨而得名。景区以翠海、叠瀑、彩林、雪峰和藏族风情为主要特色，湖泊由钙华沉积形成，湖水清澈透亮，在阳光下呈现蓝、绿、黄等斑斓色彩，被称为“海子”。五花海、长海、诺日朗瀑布等景点闻名遐迩，秋季彩林层叠时尤为绚丽。九寨沟是世界自然遗产，也是国家级自然保护区，有“童话世界”之称。

开放时间：旺季 08:00-17:00，实行限量预约
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。', '/media/images/jiuzhaigou_thumb.webp', NULL, NULL, 80.00, 4.9, 456780, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 22 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(1, '秦始皇兵马俑', '陕西省', '西安市', '陕西省西安市临潼区秦陵北路', 109.273300, 34.385300, '08:30-18:00，16:30 停止入馆', '秦始皇兵马俑位于陕西省西安市临潼区，是秦始皇陵的大型陪葬坑，于上世纪七十年代由当地农民打井时偶然发现。坑内出土了大量按照真人比例塑造的陶俑和陶马，排列成严整的军阵，人物神态、发式、衣着各不相同，展现了秦代高超的雕塑与制陶工艺。如今已建成秦始皇帝陵博物院对外开放，秦始皇陵及兵马俑坑被列入世界文化遗产，被誉为“世界第八大奇迹”。', '秦始皇兵马俑位于陕西省西安市临潼区，是秦始皇陵的大型陪葬坑，于上世纪七十年代由当地农民打井时偶然发现。坑内出土了大量按照真人比例塑造的陶俑和陶马，排列成严整的军阵，人物神态、发式、衣着各不相同，展现了秦代高超的雕塑与制陶工艺。如今已建成秦始皇帝陵博物院对外开放，秦始皇陵及兵马俑坑被列入世界文化遗产，被誉为“世界第八大奇迹”。

开放时间：08:30-18:00，16:30 停止入馆
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。', '/media/images/bingmayong_thumb.webp', 'https://upload.wikimedia.org/wikipedia/commons/c/c4/Terracotta_Army_Pit_1_2014.webmhd.webm', 'Bairuilong · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:Terracotta_Army_Pit_1_2014.webmhd.webm', 60.00, 4.8, 710200, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 21 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(2, '桂林漓江', '广西壮族自治区', '桂林市', '广西壮族自治区桂林市阳朔县漓江景区', 110.434000, 25.100000, '竹筏与游船按航班，约 08:00-16:30', '桂林漓江位于广西壮族自治区桂林市，是典型的喀斯特岩溶地貌河流。从桂林至阳朔的漓江水路，两岸奇峰林立、倒影如画，江水清澈蜿蜒，竹筏、渔舟与田园村落点缀其间，构成一幅天然的山水长卷。九马画山、黄布倒影、兴坪佳境等景点久负盛名，人民币背面图案亦取景于此。桂林山水自古享有“桂林山水甲天下”的美誉，漓江游船和竹筏是体验这片山水的经典方式。', '桂林漓江位于广西壮族自治区桂林市，是典型的喀斯特岩溶地貌河流。从桂林至阳朔的漓江水路，两岸奇峰林立、倒影如画，江水清澈蜿蜒，竹筏、渔舟与田园村落点缀其间，构成一幅天然的山水长卷。九马画山、黄布倒影、兴坪佳境等景点久负盛名，人民币背面图案亦取景于此。桂林山水自古享有“桂林山水甲天下”的美誉，漓江游船和竹筏是体验这片山水的经典方式。

开放时间：竹筏与游船按航班，约 08:00-16:30
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。', '/media/images/lijiang_guilin_thumb.webp', NULL, NULL, 107.50, 4.7, 298600, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 20 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(5, '布达拉宫', '西藏自治区', '拉萨市', '西藏自治区拉萨市城关区北京中路35号', 91.117500, 29.655500, '旺季约 09:00 起分时段参观，须提前预约', '布达拉宫位于西藏自治区拉萨市中心的红山之上，是一座集宫殿、城堡和寺院于一体的宏伟建筑群，始建于吐蕃王朝松赞干布时期，后经多次扩建形成今日规模。宫殿依山而建，主体分为白宫和红宫，殿堂内保存着大量壁画、佛像、经书和灵塔等珍贵文物，是藏式建筑艺术的杰出代表。布达拉宫已列入世界文化遗产名录，是藏传佛教文化的重要象征，也是游客来到拉萨的必访之地。', '布达拉宫位于西藏自治区拉萨市中心的红山之上，是一座集宫殿、城堡和寺院于一体的宏伟建筑群，始建于吐蕃王朝松赞干布时期，后经多次扩建形成今日规模。宫殿依山而建，主体分为白宫和红宫，殿堂内保存着大量壁画、佛像、经书和灵塔等珍贵文物，是藏式建筑艺术的杰出代表。布达拉宫已列入世界文化遗产名录，是藏传佛教文化的重要象征，也是游客来到拉萨的必访之地。

开放时间：旺季约 09:00 起分时段参观，须提前预约
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。', '/media/images/budalagong_thumb.webp', 'https://upload.wikimedia.org/wikipedia/commons/b/be/%E2%80%9C%E5%86%AC%E6%B8%B8%E8%A5%BF%E8%97%8F%E2%80%9D%E8%BF%9B%E8%A1%8C%E6%97%B6_%E6%B8%B8%E5%AE%A2%E5%85%8D%E8%B4%B9%E6%B8%B8%E8%A7%88%E5%B8%83%E8%BE%BE%E6%8B%89%E5%AE%AB.webm', '中国新闻社 · CC BY 3.0 · https://commons.wikimedia.org/wiki/File:%E2%80%9C%E5%86%AC%E6%B8%B8%E8%A5%BF%E8%97%8F%E2%80%9D%E8%BF%9B%E8%A1%8C%E6%97%B6_%E6%B8%B8%E5%AE%A2%E5%85%8D%E8%B4%B9%E6%B8%B8%E8%A7%88%E5%B8%83%E8%BE%BE%E6%8B%89%E5%AE%AB.webm', 100.00, 4.9, 256800, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 19 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(6, '厦门鼓浪屿', '福建省', '厦门市', '福建省厦门市思明区鼓浪屿', 118.066800, 24.447800, '岛屿全天可步行，轮渡约 06:00-22:00', '鼓浪屿位于福建省厦门市思明区，是与厦门岛隔海相望的一座小岛，因岛西南海边礁石受浪潮冲击声如擂鼓而得名。岛上禁止机动车通行，街巷幽静，保存有大量中西合璧的近代建筑，如别墅、教堂和领事馆旧址，日光岩、菽庄花园、皓月园等是热门景点。鼓浪屿钢琴拥有密度高，被称为“钢琴之岛”和“音乐之乡”。“鼓浪屿：历史国际社区”已被列入世界文化遗产名录。', '鼓浪屿位于福建省厦门市思明区，是与厦门岛隔海相望的一座小岛，因岛西南海边礁石受浪潮冲击声如擂鼓而得名。岛上禁止机动车通行，街巷幽静，保存有大量中西合璧的近代建筑，如别墅、教堂和领事馆旧址，日光岩、菽庄花园、皓月园等是热门景点。鼓浪屿钢琴拥有密度高，被称为“钢琴之岛”和“音乐之乡”。“鼓浪屿：历史国际社区”已被列入世界文化遗产名录。

开放时间：岛屿全天可步行，轮渡约 06:00-22:00
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。', '/media/images/gulangyu_thumb.webp', NULL, NULL, 17.50, 4.7, 334500, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 28 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(2, '泰山', '山东省', '泰安市', '山东省泰安市泰山区红门路', 117.101000, 36.256000, '全天开放，索道约 06:30-17:00', '泰山位于山东省中部，主体横跨泰安、济南等地，古称岱山、岱宗，居五岳之首，有“五岳独尊”之称。历代帝王多在此举行封禅大典，山中留下了大量古建筑、石刻和碑碣，岱庙、红门、中天门、南天门、玉皇顶等沿登山步道依次分布。登临绝顶可观旭日东升、云海玉盘等奇景，“会当凌绝顶，一览众山小”的诗句正源于此。泰山是中国首个世界文化与自然双重遗产。', '泰山位于山东省中部，主体横跨泰安、济南等地，古称岱山、岱宗，居五岳之首，有“五岳独尊”之称。历代帝王多在此举行封禅大典，山中留下了大量古建筑、石刻和碑碣，岱庙、红门、中天门、南天门、玉皇顶等沿登山步道依次分布。登临绝顶可观旭日东升、云海玉盘等奇景，“会当凌绝顶，一览众山小”的诗句正源于此。泰山是中国首个世界文化与自然双重遗产。

开放时间：全天开放，索道约 06:30-17:00
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。', '/media/images/taishan_thumb.webp', NULL, NULL, 57.50, 4.8, 402330, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 27 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(1, '丽江古城', '云南省', '丽江市', '云南省丽江市古城区', 100.234000, 26.872000, '古城全天开放，部分院落另计', '丽江古城位于云南省丽江市古城区，又名大研古镇，是以纳西族为主体的历史文化名城。古城依山傍水而建，没有城墙，玉龙雪山融水经水渠穿街绕巷，形成“家家流水、户户垂杨”的独特格局。四方街是古城的中心，石板路、木结构民居和小桥流水错落有致，纳西古乐与东巴文化在此传承。丽江古城被列入世界文化遗产名录，是体验滇西北民族风情和高原古镇生活的热门目的地。', '丽江古城位于云南省丽江市古城区，又名大研古镇，是以纳西族为主体的历史文化名城。古城依山傍水而建，没有城墙，玉龙雪山融水经水渠穿街绕巷，形成“家家流水、户户垂杨”的独特格局。四方街是古城的中心，石板路、木结构民居和小桥流水错落有致，纳西古乐与东巴文化在此传承。丽江古城被列入世界文化遗产名录，是体验滇西北民族风情和高原古镇生活的热门目的地。

开放时间：古城全天开放，部分院落另计
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。', '/media/images/lijiang_gucheng_thumb.webp', 'https://upload.wikimedia.org/wikipedia/commons/e/e8/Lijiang%2C_Yunnan_The_Most_Beautiful_Fairytale_Town_in_China_%284K_UHD%29.webm', 'DuckTravel (World Tourist Channel) · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:Lijiang,_Yunnan_The_Most_Beautiful_Fairytale_Town_in_China_(4K_UHD).webm', 0.00, 4.7, 512900, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 26 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(3, '苏州拙政园', '江苏省', '苏州市', '江苏省苏州市姑苏区东北街178号', 120.629000, 31.324000, '07:30-17:30，16:30 停止入园', '拙政园位于江苏省苏州市姑苏区，始建于明代正德年间，是江南古典园林的代表作，与北京颐和园、承德避暑山庄、苏州留园并称中国四大名园。全园以水为中心，分为东、中、西三部分，亭台楼榭临水而建，花木扶疏，借景、对景等造园手法运用精妙，远香堂、小飞虹、见山楼等景点各具意境。拙政园作为苏州古典园林的组成部分，已被列入世界文化遗产名录。', '拙政园位于江苏省苏州市姑苏区，始建于明代正德年间，是江南古典园林的代表作，与北京颐和园、承德避暑山庄、苏州留园并称中国四大名园。全园以水为中心，分为东、中、西三部分，亭台楼榭临水而建，花木扶疏，借景、对景等造园手法运用精妙，远香堂、小飞虹、见山楼等景点各具意境。拙政园作为苏州古典园林的组成部分，已被列入世界文化遗产名录。

开放时间：07:30-17:30，16:30 停止入园
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。', '/media/images/zhuozhengyuan_thumb.webp', NULL, NULL, 45.00, 4.8, 287400, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 25 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(4, '上海外滩', '上海市', '上海市', '上海市黄浦区中山东一路', 121.490500, 31.241600, '外滩步道全天开放', '上海外滩位于上海市黄浦区黄浦江西岸，是上海最具代表性的城市地标。沿江矗立着一批风格各异的近代建筑，涵盖哥特式、巴洛克式、新古典主义、装饰艺术等多种样式，被称为“万国建筑博览群”，见证了上海开埠以来的历史变迁。漫步外滩观景平台，可隔江眺望陆家嘴的东方明珠、上海中心大厦等摩天楼群。白天可赏建筑与江景，入夜灯光璀璨，是游客感受上海都市魅力的首选。', '上海外滩位于上海市黄浦区黄浦江西岸，是上海最具代表性的城市地标。沿江矗立着一批风格各异的近代建筑，涵盖哥特式、巴洛克式、新古典主义、装饰艺术等多种样式，被称为“万国建筑博览群”，见证了上海开埠以来的历史变迁。漫步外滩观景平台，可隔江眺望陆家嘴的东方明珠、上海中心大厦等摩天楼群。白天可赏建筑与江景，入夜灯光璀璨，是游客感受上海都市魅力的首选。

开放时间：外滩步道全天开放
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。', '/media/images/waitan_thumb.webp', 'https://upload.wikimedia.org/wikipedia/commons/9/91/Shanghai_Bund%2C_Lujiazui_Skyline_Timelapse.webm', 'Yigang Yu · CC0 · https://commons.wikimedia.org/wiki/File:Shanghai_Bund,_Lujiazui_Skyline_Timelapse.webm', 0.00, 4.8, 688200, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 24 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(1, '曲阜三孔', '山东省', '济宁市', '山东省济宁市曲阜市神道路', 116.986500, 35.596600, '08:00-17:20，孔庙孔府孔林联票', '曲阜三孔位于山东省济宁市曲阜市，指孔庙、孔府和孔林，是纪念和传承孔子及其后裔的重要遗存。孔庙是历代祭祀孔子的场所，大成殿与北京故宫太和殿、泰山岱庙天贶殿并称为中国古代三大殿；孔府是孔子嫡系后裔居住和办公的府邸；孔林则是孔子及其家族的墓地，古木参天。三孔集中体现了儒家文化的深厚底蕴，已被列入世界文化遗产名录，是了解中国传统文化的重要场所。', '曲阜三孔位于山东省济宁市曲阜市，指孔庙、孔府和孔林，是纪念和传承孔子及其后裔的重要遗存。孔庙是历代祭祀孔子的场所，大成殿与北京故宫太和殿、泰山岱庙天贶殿并称为中国古代三大殿；孔府是孔子嫡系后裔居住和办公的府邸；孔林则是孔子及其家族的墓地，古木参天。三孔集中体现了儒家文化的深厚底蕴，已被列入世界文化遗产名录，是了解中国传统文化的重要场所。

开放时间：08:00-17:20，孔庙孔府孔林联票
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。', '/media/images/qufu_sankong_thumb.webp', NULL, NULL, 40.00, 4.7, 198400, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 23 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(5, '峨眉山', '四川省', '乐山市', '四川省乐山市峨眉山市名山南路', 103.336000, 29.525000, '全天开放，金顶索道约 07:00-18:00', '峨眉山位于四川省乐山市峨眉山市，是中国四大佛教名山之一，相传为普贤菩萨的道场。山势雄伟，植被茂密，从山脚到金顶气候与植被垂直变化明显，有“峨眉天下秀”之誉。报国寺、万年寺、清音阁、洗象池等寺庙古迹沿山分布，山中常见野生猕猴。登上金顶可观日出、云海、佛光和圣灯等奇观。峨眉山与乐山大佛共同被列入世界文化与自然双重遗产名录。', '峨眉山位于四川省乐山市峨眉山市，是中国四大佛教名山之一，相传为普贤菩萨的道场。山势雄伟，植被茂密，从山脚到金顶气候与植被垂直变化明显，有“峨眉天下秀”之誉。报国寺、万年寺、清音阁、洗象池等寺庙古迹沿山分布，山中常见野生猕猴。登上金顶可观日出、云海、佛光和圣灯等奇观。峨眉山与乐山大佛共同被列入世界文化与自然双重遗产名录。

开放时间：全天开放，金顶索道约 07:00-18:00
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。', '/media/images/emeishan_thumb.webp', NULL, NULL, 80.00, 4.8, 276500, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 22 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(5, '乐山大佛', '四川省', '乐山市', '四川省乐山市市中区凌云路', 103.773000, 29.544000, '07:30-18:30，17:30 停止购票', '乐山大佛位于四川省乐山市，地处岷江、青衣江和大渡河三江汇流处，依凌云山栖霞峰临江峭壁凿造而成，是一尊弥勒佛坐像。大佛开凿于唐代，历时约九十年方告完成，是世界上现存最大的古代石刻佛像之一。佛像头与山齐、足踏大江，体内外设有精巧的排水系统，千余年来保存较好。游客可沿九曲栈道近观，也可乘船在江上眺望全貌。乐山大佛与峨眉山同属世界双重遗产。', '乐山大佛位于四川省乐山市，地处岷江、青衣江和大渡河三江汇流处，依凌云山栖霞峰临江峭壁凿造而成，是一尊弥勒佛坐像。大佛开凿于唐代，历时约九十年方告完成，是世界上现存最大的古代石刻佛像之一。佛像头与山齐、足踏大江，体内外设有精巧的排水系统，千余年来保存较好。游客可沿九曲栈道近观，也可乘船在江上眺望全貌。乐山大佛与峨眉山同属世界双重遗产。

开放时间：07:30-18:30，17:30 停止购票
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。', '/media/images/leshan_dafo_thumb.webp', NULL, NULL, 40.00, 4.7, 241800, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 21 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(4, '重庆洪崖洞', '重庆市', '重庆市', '重庆市渝中区嘉陵江滨江路88号', 106.578000, 29.562000, '全天开放，夜景约至 23:00', '洪崖洞位于重庆市渝中区，地处嘉陵江畔的悬崖峭壁之上，是以巴渝传统吊脚楼风貌为特色的商业文化街区。建筑依山就势、层层叠叠，沿崖壁分布多层街巷，融合了餐饮、民俗、观景等多种功能，充分展现了重庆“山城”立体建筑的独特魅力。从江边或对岸望去，吊脚楼群与现代高楼相映成趣，夜晚灯火通明时更显梦幻。这里还可眺望嘉陵江与千厮门大桥，是重庆最热门的打卡地之一。', '洪崖洞位于重庆市渝中区，地处嘉陵江畔的悬崖峭壁之上，是以巴渝传统吊脚楼风貌为特色的商业文化街区。建筑依山就势、层层叠叠，沿崖壁分布多层街巷，融合了餐饮、民俗、观景等多种功能，充分展现了重庆“山城”立体建筑的独特魅力。从江边或对岸望去，吊脚楼群与现代高楼相映成趣，夜晚灯火通明时更显梦幻。这里还可眺望嘉陵江与千厮门大桥，是重庆最热门的打卡地之一。

开放时间：全天开放，夜景约至 23:00
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。', '/media/images/hongyadong_thumb.webp', NULL, NULL, 0.00, 4.6, 455600, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 20 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(5, '敦煌莫高窟', '甘肃省', '酒泉市敦煌市', '甘肃省酒泉市敦煌市莫高镇', 94.808000, 40.041000, '08:00-18:00，洞窟分时段预约', '敦煌莫高窟位于甘肃省酒泉市敦煌市东南的鸣沙山东麓崖壁上，俗称千佛洞，始凿于十六国时期，历经北朝、隋、唐、五代、西夏、元等朝代的持续营建。洞窟中保存有大量精美的壁画和彩塑，内容涵盖佛教故事、经变画、供养人像及社会生活场景，是世界上现存规模最大、内容最丰富的佛教艺术地之一。藏经洞出土的文献更催生了“敦煌学”。莫高窟已列入世界文化遗产名录。', '敦煌莫高窟位于甘肃省酒泉市敦煌市东南的鸣沙山东麓崖壁上，俗称千佛洞，始凿于十六国时期，历经北朝、隋、唐、五代、西夏、元等朝代的持续营建。洞窟中保存有大量精美的壁画和彩塑，内容涵盖佛教故事、经变画、供养人像及社会生活场景，是世界上现存规模最大、内容最丰富的佛教艺术地之一。藏经洞出土的文献更催生了“敦煌学”。莫高窟已列入世界文化遗产名录。

开放时间：08:00-18:00，洞窟分时段预约
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。', '/media/images/mogaoku_thumb.webp', 'https://upload.wikimedia.org/wikipedia/commons/2/26/Mogao_Caves_2014.webmhd.webm', 'Bairuilong · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:Mogao_Caves_2014.webmhd.webm', 119.00, 4.9, 186500, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 19 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(6, '三亚亚龙湾', '海南省', '三亚市', '海南省三亚市吉阳区亚龙湾', 109.641000, 18.231000, '海湾全天开放', '亚龙湾位于海南省三亚市东南部，是一处呈新月形的热带海湾，三面青山环抱、一面向海。这里沙滩平缓宽阔，沙粒洁白细软，海水清澈湛蓝，能见度高，适宜游泳、潜水、帆船等多种海上活动，海底拥有丰富的珊瑚礁与热带鱼类。湾区内分布有众多度假酒店，周边还有亚龙湾热带天堂森林公园等景点。凭借优美的海景和舒适的气候，亚龙湾被誉为“天下第一湾”，是热门的滨海度假胜地。', '亚龙湾位于海南省三亚市东南部，是一处呈新月形的热带海湾，三面青山环抱、一面向海。这里沙滩平缓宽阔，沙粒洁白细软，海水清澈湛蓝，能见度高，适宜游泳、潜水、帆船等多种海上活动，海底拥有丰富的珊瑚礁与热带鱼类。湾区内分布有众多度假酒店，周边还有亚龙湾热带天堂森林公园等景点。凭借优美的海景和舒适的气候，亚龙湾被誉为“天下第一湾”，是热门的滨海度假胜地。

开放时间：海湾全天开放
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。', '/media/images/yalongwan_thumb.webp', NULL, NULL, 0.00, 4.7, 302100, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 28 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(4, '哈尔滨中央大街', '黑龙江省', '哈尔滨市', '黑龙江省哈尔滨市道里区中央大街', 126.641000, 45.773000, '步行街全天开放', '哈尔滨中央大街位于黑龙江省哈尔滨市道里区，北起松花江畔的防洪纪念塔，南接经纬街，是一条历史悠久的步行商业街。街道铺设着方块石路面，两侧汇集了文艺复兴、巴洛克、新艺术运动等多种风格的欧式建筑，充满异域风情，被称为“建筑艺术博物馆”。街上商铺、餐厅与老字号林立，马迭尔冰棍等特色美食深受游客喜爱。冬季这里还会举办冰雪活动，是体验哈尔滨城市风情的首选地。', '哈尔滨中央大街位于黑龙江省哈尔滨市道里区，北起松花江畔的防洪纪念塔，南接经纬街，是一条历史悠久的步行商业街。街道铺设着方块石路面，两侧汇集了文艺复兴、巴洛克、新艺术运动等多种风格的欧式建筑，充满异域风情，被称为“建筑艺术博物馆”。街上商铺、餐厅与老字号林立，马迭尔冰棍等特色美食深受游客喜爱。冬季这里还会举办冰雪活动，是体验哈尔滨城市风情的首选地。

开放时间：步行街全天开放
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。', '/media/images/zhongyangdajie_thumb.webp', 'https://upload.wikimedia.org/wikipedia/commons/5/57/Zhongyang_Dajie%2C_Harbin.webm', 'Techyan · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:Zhongyang_Dajie,_Harbin.webm', 0.00, 4.6, 268400, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 27 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(2, '张掖丹霞', '甘肃省', '张掖市', '甘肃省张掖市临泽县倪家营镇', 100.100000, 38.960000, '旺季 06:00-18:00，建议傍晚入园', '张掖丹霞位于甘肃省张掖市临泽县和肃南裕固族自治县境内，是张掖丹霞国家地质公园的核心景区。这里的七彩丹霞地貌由红色砂岩、砾岩等在长期沉积和风化侵蚀作用下形成，山体层理分明，红、黄、橙、绿、白等色彩交错，在阳光照射下绚丽夺目，宛如打翻的调色盘。日出和日落时分光影变幻尤为壮观。景区建有多处观景台和栈道，是摄影爱好者和游客竞相前往的地质奇观。', '张掖丹霞位于甘肃省张掖市临泽县和肃南裕固族自治县境内，是张掖丹霞国家地质公园的核心景区。这里的七彩丹霞地貌由红色砂岩、砾岩等在长期沉积和风化侵蚀作用下形成，山体层理分明，红、黄、橙、绿、白等色彩交错，在阳光照射下绚丽夺目，宛如打翻的调色盘。日出和日落时分光影变幻尤为壮观。景区建有多处观景台和栈道，是摄影爱好者和游客竞相前往的地质奇观。

开放时间：旺季 06:00-18:00，建议傍晚入园
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。', '/media/images/zhangye_danxia_thumb.webp', NULL, NULL, 37.00, 4.8, 221300, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 26 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(2, '黄果树瀑布', '贵州省', '安顺市', '贵州省安顺市镇宁布依族苗族自治县', 105.671000, 25.992000, '07:00-18:00', '黄果树瀑布位于贵州省安顺市镇宁布依族苗族自治县，地处白水河上，是中国最著名的大型瀑布之一，也是世界知名的喀斯特瀑布群代表。瀑布从断崖顶端倾泻而下，水势浩大、声如雷鸣，水雾弥漫，晴天时常可见彩虹。瀑布后方有一条天然形成的水帘洞，游客可穿行其中从内部观赏飞瀑。景区周边还有陡坡塘瀑布、天星桥等景点，与黄果树大瀑布共同构成壮丽的瀑布群景观。', '黄果树瀑布位于贵州省安顺市镇宁布依族苗族自治县，地处白水河上，是中国最著名的大型瀑布之一，也是世界知名的喀斯特瀑布群代表。瀑布从断崖顶端倾泻而下，水势浩大、声如雷鸣，水雾弥漫，晴天时常可见彩虹。瀑布后方有一条天然形成的水帘洞，游客可穿行其中从内部观赏飞瀑。景区周边还有陡坡塘瀑布、天星桥等景点，与黄果树大瀑布共同构成壮丽的瀑布群景观。

开放时间：07:00-18:00
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。
影像说明：片头为张家界，后半段为黄果树瀑布（共用）。', '/media/images/huangguoshu_thumb.webp', 'https://upload.wikimedia.org/wikipedia/commons/4/40/2019%E5%B9%B41%E6%9C%883%E6%97%A5_%E5%BC%A0%E5%AE%B6%E7%95%8C%E9%9B%AA%E5%90%8E%E9%9B%BE%E5%87%87%E4%BA%91%E6%B5%B7%E6%9C%A6%E8%83%A7%E5%A6%82%E4%BB%99%E5%A2%83.webm', '片头为张家界，后半段为黄果树瀑布（共用） · 中国新闻网 · CC BY 3.0 · https://commons.wikimedia.org/wiki/File:2019%E5%B9%B41%E6%9C%883%E6%97%A5_%E5%BC%A0%E5%AE%B6%E7%95%8C%E9%9B%AA%E5%90%8E%E9%9B%BE%E5%87%87%E4%BA%91%E6%B5%B7%E6%9C%A6%E8%83%A7%E5%A6%82%E4%BB%99%E5%A2%83.webm', 80.00, 4.7, 254900, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 25 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY)),
(1, '平遥古城', '山西省', '晋中市', '山西省晋中市平遥县古城内', 112.176000, 37.201000, '古城全天，城墙与院落约 08:00-18:00', '平遥古城位于山西省晋中市平遥县，是中国目前保存最为完整的古代县城之一，基本保留了明清时期的城市格局与风貌。古城墙环绕全城，城内街巷纵横、店铺林立，市楼、县衙、文庙等古建筑分布其间，大量传统民居院落保存完好。这里是“日昇昌”票号的所在地，被视为中国近代金融业的发源地之一。平遥古城已被列入世界文化遗产名录，每年举办的平遥国际摄影大展也颇具影响。', '平遥古城位于山西省晋中市平遥县，是中国目前保存最为完整的古代县城之一，基本保留了明清时期的城市格局与风貌。古城墙环绕全城，城内街巷纵横、店铺林立，市楼、县衙、文庙等古建筑分布其间，大量传统民居院落保存完好。这里是“日昇昌”票号的所在地，被视为中国近代金融业的发源地之一。平遥古城已被列入世界文化遗产名录，每年举办的平遥国际摄影大展也颇具影响。

开放时间：古城全天，城墙与院落约 08:00-18:00
票价为课程演示数据，以景区当日公示为准。图片作者与许可写在图注中，汇总见《素材署名》。', '/media/images/pingyao_thumb.webp', NULL, NULL, 62.50, 4.7, 233800, 1, DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 24 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:00:00'), INTERVAL 2 DAY));
INSERT INTO spot_image (spot_id, url, caption, credit, sort_order) VALUES
(1, '/media/images/gugong_1.webp', '故宫 · 1', 'xiquinhosilva · CC BY 2.0 · https://commons.wikimedia.org/wiki/File:Golden_Water_River_at_the_Forbidden_City_03.jpg', 1),
(1, '/media/images/gugong_2.webp', '故宫 · 2', 'User:kallgan · CC BY-SA 3.0 · https://commons.wikimedia.org/wiki/File:Sunset_of_the_Forbidden_City_2006.JPG', 2),
(1, '/media/images/gugong_3.webp', '故宫 · 3', 'Ermell · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:Beijing_forbidden_city_Belvedere_of_Embodying_Benevolence-20071018-RM-142403.jpg', 3),
(2, '/media/images/badaling_1.webp', '八达岭长城 · 1', 'CEphoto, Uwe Aranas · CC BY-SA 3.0 · https://commons.wikimedia.org/wiki/File:Badaling_China_Great-Wall-of-China-01.jpg', 1),
(2, '/media/images/badaling_2.webp', '八达岭长城 · 2', 'CEphoto, Uwe Aranas · CC BY-SA 3.0 · https://commons.wikimedia.org/wiki/File:Badaling_China_Great-Wall-of-China-02.jpg', 2),
(2, '/media/images/badaling_3.webp', '八达岭长城 · 3', 'Reinhold Möller Ermell · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:Peking_Grosse_Mauer-20071019-RM-114506.jpg', 3),
(3, '/media/images/xihu_1.webp', '杭州西湖 · 1', 'DXR · CC BY-SA 3.0 · https://commons.wikimedia.org/wiki/File:West_Lake_Pavilion_and_Water_Lilies,_Hangzhou_120529_1.jpg', 1),
(3, '/media/images/xihu_2.webp', '杭州西湖 · 2', 'Takashishin · CC BY 4.0 · https://commons.wikimedia.org/wiki/File:West_Lake,_Hangzhou_2025.jpg', 2),
(3, '/media/images/xihu_3.webp', '杭州西湖 · 3', 'Windmemories · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:20260424_West_Lake_and_Xiling_Bridge.jpg', 3),
(4, '/media/images/huangshan_1.webp', '黄山 · 1', 'xiquinhosilva · CC BY 2.0 · https://commons.wikimedia.org/wiki/File:Mount-huangshan_53319732882_o.jpg', 1),
(4, '/media/images/huangshan_2.webp', '黄山 · 2', 'xiquinhosilva · CC BY 2.0 · https://commons.wikimedia.org/wiki/File:Mount-huangshan_53320601421_o.jpg', 2),
(4, '/media/images/huangshan_3.webp', '黄山 · 3', 'Chi King · CC BY 2.0 · https://commons.wikimedia.org/wiki/File:Huangshan_pic_4.jpg', 3),
(5, '/media/images/zhangjiajie_1.webp', '张家界国家森林公园 · 1', 'Kuruman from Tokyo, Japan · CC BY 2.0 · https://commons.wikimedia.org/wiki/File:Zhangjiajie_National_Forest_Park.jpg', 1),
(5, '/media/images/zhangjiajie_2.webp', '张家界国家森林公园 · 2', 'xiquinhosilva · CC BY 2.0 · https://commons.wikimedia.org/wiki/File:Zhangjiajie_National_Forest_Park_38023-Zhangjiajie_(48757574461).jpg', 2),
(5, '/media/images/zhangjiajie_3.webp', '张家界国家森林公园 · 3', 'xiquinhosilva · CC BY 2.0 · https://commons.wikimedia.org/wiki/File:Zhangjiajie_National_Forest_Park_38021-Zhangjiajie_(48757252178).jpg', 3),
(6, '/media/images/jiuzhaigou_1.webp', '九寨沟 · 1', 'Chensiyuan · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:1_jiuzhaigou_valley_wu_hua_hai_2011b.jpg', 1),
(6, '/media/images/jiuzhaigou_2.webp', '九寨沟 · 2', 'Jean-Marie Hullot from France · CC BY 2.0 · https://commons.wikimedia.org/wiki/File:Rhinoceros_Lake,_Jiuzhaigou_Valley.jpg', 2),
(6, '/media/images/jiuzhaigou_3.webp', '九寨沟 · 3', 'Culantor Lin · CC BY-SA 2.0 · https://commons.wikimedia.org/wiki/File:%E4%B9%9D%E5%AF%A8%E6%BA%9D-%E8%80%81%E8%99%8E%E6%B5%B7_Jiuzhaigou_Tiger_Lake.jpg', 3),
(7, '/media/images/bingmayong_1.webp', '秦始皇兵马俑 · 1', 'Jmhullot · CC BY 3.0 · https://commons.wikimedia.org/wiki/File:Terracotta_Army,_View_of_Pit_1.jpg', 1),
(7, '/media/images/bingmayong_2.webp', '秦始皇兵马俑 · 2', 'Gary Todd · CC0 · https://commons.wikimedia.org/wiki/File:Qin_Shihuang_Terracotta_Army,_Pit_1.jpg', 2),
(7, '/media/images/bingmayong_3.webp', '秦始皇兵马俑 · 3', 'Ideophagous · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:Terracotta_army_(32472).jpg', 3),
(8, '/media/images/lijiang_guilin_1.webp', '桂林漓江 · 1', 'chensiyuan · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:1_li_jiang_guilin_yangshuo_2011.jpg', 1),
(8, '/media/images/lijiang_guilin_2.webp', '桂林漓江 · 2', 'Flora-Victoria · CC0 · https://commons.wikimedia.org/wiki/File:Li_River_cruise_from_Guilin_to_Yangshuo.JPG', 2),
(8, '/media/images/lijiang_guilin_3.webp', '桂林漓江 · 3', 'swithland · CC BY 3.0 · https://commons.wikimedia.org/wiki/File:Li_River_Guilin_China_-_panoramio_(5).jpg', 3),
(9, '/media/images/budalagong_1.webp', '布达拉宫 · 1', 'Antoine Taveneaux · CC BY-SA 3.0 · https://commons.wikimedia.org/wiki/File:Potala_Palace,_August_2009.jpg', 1),
(9, '/media/images/budalagong_2.webp', '布达拉宫 · 2', 'Antoine Taveneaux · CC BY-SA 3.0 · https://commons.wikimedia.org/wiki/File:Potala_palace24.jpg', 2),
(9, '/media/images/budalagong_3.webp', '布达拉宫 · 3', 'Laika ac from UK · CC BY-SA 2.0 · https://commons.wikimedia.org/wiki/File:Potala_Palace_(23651397662).jpg', 3),
(10, '/media/images/gulangyu_1.webp', '厦门鼓浪屿 · 1', 'gdczjkk · CC BY 3.0 · https://commons.wikimedia.org/wiki/File:%E9%BC%93%E6%B5%AA%E5%B1%BF_-_panoramio.jpg', 1),
(10, '/media/images/gulangyu_2.webp', '厦门鼓浪屿 · 2', 'JULIANISME · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:High_tide_on_Gulangyu_beach_20230827_03.jpg', 2),
(10, '/media/images/gulangyu_3.webp', '厦门鼓浪屿 · 3', 'Rolfmueller · CC BY-SA 3.0 · https://commons.wikimedia.org/wiki/File:Gulangyu_mansion_2011_12.jpg', 3),
(11, '/media/images/taishan_1.webp', '泰山 · 1', 'Jari Kirma · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:A_view_from_Mount_Tai.jpg', 1),
(11, '/media/images/taishan_2.webp', '泰山 · 2', 'xiquinhosilva · CC BY 2.0 · https://commons.wikimedia.org/wiki/File:50577-_Half_Way_Gate_to_Heaven,_Mount_Tai_%E6%B3%B0%E5%B1%B1%E4%B8%AD%E5%A4%A9%E9%97%A8%E7%B4%A2%E9%81%93%E7%AB%99.jpg', 2),
(11, '/media/images/taishan_3.webp', '泰山 · 3', 'xiquinhosilva · CC BY 2.0 · https://commons.wikimedia.org/wiki/File:50549-Mount_Tai-Taishan_%E6%B3%B0%E5%B1%B1.jpg', 3),
(12, '/media/images/lijiang_gucheng_1.webp', '丽江古城 · 1', 'CEphoto, Uwe Aranas · CC BY-SA 3.0 · https://commons.wikimedia.org/wiki/File:Lijiang_Yunnan_Old-town-03.jpg', 1),
(12, '/media/images/lijiang_gucheng_2.webp', '丽江古城 · 2', 'chensiyuan · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:1_lijiang_old_town_2012a.jpg', 2),
(12, '/media/images/lijiang_gucheng_3.webp', '丽江古城 · 3', 'CEphoto, Uwe Aranas · CC BY-SA 3.0 · https://commons.wikimedia.org/wiki/File:Lijiang_Yunnan_Old-town-02.jpg', 3),
(13, '/media/images/zhuozhengyuan_1.webp', '苏州拙政园 · 1', 'King of Hearts · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:Humble_Administrator%27s_Garden_Suzhou_November_2017_007.jpg', 1),
(13, '/media/images/zhuozhengyuan_2.webp', '苏州拙政园 · 2', 'King of Hearts · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:Humble_Administrator%27s_Garden_Suzhou_November_2017_005.jpg', 2),
(13, '/media/images/zhuozhengyuan_3.webp', '苏州拙政园 · 3', 'King of Hearts · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:Humble_Administrator%27s_Garden_Suzhou_November_2017_006.jpg', 3),
(14, '/media/images/waitan_1.webp', '上海外滩 · 1', 'xiquinhosilva · CC BY 2.0 · https://commons.wikimedia.org/wiki/File:20264-Shanghai,_The_Bund.jpg', 1),
(14, '/media/images/waitan_2.webp', '上海外滩 · 2', 'Ermell · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:Shanghai_Bund-20150516-RM-173803.jpg', 2),
(14, '/media/images/waitan_3.webp', '上海外滩 · 3', 'Ermell · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:Shanghai_skyline_waterfront_pudong_A235423.jpg', 3),
(15, '/media/images/qufu_sankong_1.webp', '曲阜三孔 · 1', 'Gary Todd from Xinzheng, China · CC0 · https://commons.wikimedia.org/wiki/File:Kongzi_(Confucius)_Temple,_Qufu_(13035569695).jpg', 1),
(15, '/media/images/qufu_sankong_2.webp', '曲阜三孔 · 2', 'Gary Todd from Xinzheng, China · CC0 · https://commons.wikimedia.org/wiki/File:Kongzi_(Confucius)_Temple,_Qufu_(13035962625).jpg', 2),
(15, '/media/images/qufu_sankong_3.webp', '曲阜三孔 · 3', 'Scott Edmunds · CC BY 2.0 · https://commons.wikimedia.org/wiki/File:Qufu_gateway_(53991070987).jpg', 3),
(16, '/media/images/emeishan_1.webp', '峨眉山 · 1', 'George N · CC BY 2.0 · https://commons.wikimedia.org/wiki/File:%E5%B3%A8%E7%9C%89%E5%B1%B1%E9%A3%8E%E6%99%AF%E5%8C%BA_Mount_Emei_Scenic_Area_07.jpg', 1),
(16, '/media/images/emeishan_2.webp', '峨眉山 · 2', 'Zhou Yuji1028 · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:Jinding.jpg', 2),
(16, '/media/images/emeishan_3.webp', '峨眉山 · 3', 'George N · CC BY 2.0 · https://commons.wikimedia.org/wiki/File:%E5%B3%A8%E7%9C%89%E5%B1%B1%E9%A3%8E%E6%99%AF%E5%8C%BA_Mount_Emei_Scenic_Area_20.jpg', 3),
(17, '/media/images/leshan_dafo_1.webp', '乐山大佛 · 1', 'xiquinhosilva · CC BY 2.0 · https://commons.wikimedia.org/wiki/File:Leshan_Giant_Buddha_(1).jpg', 1),
(17, '/media/images/leshan_dafo_2.webp', '乐山大佛 · 2', '王计 · CC BY 2.5 · https://commons.wikimedia.org/wiki/File:Leshan_Giant_Buddha,_20161102.jpg', 2),
(17, '/media/images/leshan_dafo_3.webp', '乐山大佛 · 3', 'Jan Kranendonk (https://www.jankranendonk.nl) · CC0 · https://commons.wikimedia.org/wiki/File:Leshan_giant_Buddha.jpg', 3),
(18, '/media/images/hongyadong_1.webp', '重庆洪崖洞 · 1', 'HoweyYuan · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:Hongya_Cave_20240722.jpg', 1),
(18, '/media/images/hongyadong_2.webp', '重庆洪崖洞 · 2', 'Qa003qa003 · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:Hongya_Cave_20180429_190412.jpg', 2),
(18, '/media/images/hongyadong_3.webp', '重庆洪崖洞 · 3', 'xiquinhosilva · CC BY 2.0 · https://commons.wikimedia.org/wiki/File:Hongya_Cave_20180520(2).jpg', 3),
(19, '/media/images/mogaoku_1.webp', '敦煌莫高窟 · 1', '慕尼黑啤酒 · CC BY-SA 3.0 · https://commons.wikimedia.org/wiki/File:Jiucenglou_of_Mogao_Caves.jpg', 1),
(19, '/media/images/mogaoku_2.webp', '敦煌莫高窟 · 2', 'Laika ac from UK · CC BY-SA 2.0 · https://commons.wikimedia.org/wiki/File:Mogao_Caves_(23603212609).jpg', 2),
(19, '/media/images/mogaoku_3.webp', '敦煌莫高窟 · 3', 'N509FZ · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:Caves_16-17_of_Mogao_Grottoes_(20230918142815).jpg', 3),
(20, '/media/images/yalongwan_1.webp', '三亚亚龙湾 · 1', 'Shizhao · CC BY-SA 3.0 · https://commons.wikimedia.org/wiki/File:Yalong_Bay_2007.JPG', 1),
(20, '/media/images/yalongwan_2.webp', '三亚亚龙湾 · 2', 'Tanya Dedyukhina · CC BY 3.0 · https://commons.wikimedia.org/wiki/File:Yalong_bay_-_panoramio_(19).jpg', 2),
(20, '/media/images/yalongwan_3.webp', '三亚亚龙湾 · 3', 'Tanya Dedyukhina · CC BY 3.0 · https://commons.wikimedia.org/wiki/File:Yalong_bay_Aegean_Conifer_Suites_Resort_-_panoramio_(1).jpg', 3),
(21, '/media/images/zhongyangdajie_1.webp', '哈尔滨中央大街 · 1', 'N509FZ · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:Central_Street_at_West_13th_St_(20230721112501).jpg', 1),
(21, '/media/images/zhongyangdajie_2.webp', '哈尔滨中央大街 · 2', 'Jonashtand · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:201907_Harbin_Central_Street_04.jpg', 2),
(21, '/media/images/zhongyangdajie_3.webp', '哈尔滨中央大街 · 3', 'Jonashtand · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:201907_Harbin_Central_Street_09.jpg', 3),
(22, '/media/images/zhangye_danxia_1.webp', '张掖丹霞 · 1', 'YubYub41 · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:Zhangye_Danxia.JPG', 1),
(22, '/media/images/zhangye_danxia_2.webp', '张掖丹霞 · 2', 'Terry Wu · CC BY-SA 2.0 · https://commons.wikimedia.org/wiki/File:Colourful_mountains_of_the_Zhangye_National_Geopark.jpg', 2),
(22, '/media/images/zhangye_danxia_3.webp', '张掖丹霞 · 3', 'GCScott · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:Zhangye_Danxia_Natural_Reserve.jpg', 3),
(23, '/media/images/huangguoshu_1.webp', '黄果树瀑布 · 1', 'Robinliu · CC0 · https://commons.wikimedia.org/wiki/File:Huangguoshu_Waterfall_-_Pixabay.jpg', 1),
(23, '/media/images/huangguoshu_2.webp', '黄果树瀑布 · 2', 'Huangdan2060 · CC BY 3.0 · https://commons.wikimedia.org/wiki/File:Huangguoshu_Waterfall_in_October_2020,_Picture105.jpg', 2),
(23, '/media/images/huangguoshu_3.webp', '黄果树瀑布 · 3', 'Whoisgalt · CC BY-SA 3.0 · https://commons.wikimedia.org/wiki/File:Huangguoshu_Waterfall_Guizhou_Province.jpg', 3),
(24, '/media/images/pingyao_1.webp', '平遥古城 · 1', 'Nicor · CC BY-SA 3.0 · https://commons.wikimedia.org/wiki/File:Pingyao_40.JPG', 1),
(24, '/media/images/pingyao_2.webp', '平遥古城 · 2', 'lienyuan lee · CC BY 3.0 · https://commons.wikimedia.org/wiki/File:Pingyao_Ancient_City_North_Gate_%E5%B9%B3%E9%81%99%E5%8F%A4%E5%9F%8E%E5%8C%97%E9%96%80_-_panoramio.jpg', 2),
(24, '/media/images/pingyao_3.webp', '平遥古城 · 3', '林高志 · CC BY-SA 4.0 · https://commons.wikimedia.org/wiki/File:%E4%B8%AD%E5%9C%8B%E5%B1%B1%E8%A5%BF%E5%B9%B3%E9%81%99%E5%8F%A4%E8%B9%9F631.jpg', 3);
INSERT INTO ticket_type (spot_id, name, price, description, daily_stock, status, created_at) VALUES
(1, '成人票', 60.00, '景区大门票，演示价格，以现场公示为准', 6000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(1, '优惠票', 30.00, '学生及符合条件的优惠人群，须核验证件', 2500, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(2, '成人票', 40.00, '景区大门票，演示价格，以现场公示为准', 6000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(2, '优惠票', 20.00, '学生及符合条件的优惠人群，须核验证件', 2500, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(3, '免票预约', 0.00, '开放区域免大门票，演示环境仍可生成预约订单', 20000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(3, '观光体验票', 60.00, '区间车、游船或讲解等体验项目，价格为演示值', 3000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(4, '成人票', 190.00, '景区大门票，演示价格，以现场公示为准', 6000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(4, '优惠票', 95.00, '学生及符合条件的优惠人群，须核验证件', 2500, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(5, '成人票', 225.00, '景区大门票，演示价格，以现场公示为准', 6000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(5, '优惠票', 112.50, '学生及符合条件的优惠人群，须核验证件', 2500, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(6, '成人票', 160.00, '景区大门票，演示价格，以现场公示为准', 6000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(6, '优惠票', 80.00, '学生及符合条件的优惠人群，须核验证件', 2500, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(7, '成人票', 120.00, '景区大门票，演示价格，以现场公示为准', 6000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(7, '优惠票', 60.00, '学生及符合条件的优惠人群，须核验证件', 2500, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(8, '成人票', 215.00, '景区大门票，演示价格，以现场公示为准', 6000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(8, '优惠票', 107.50, '学生及符合条件的优惠人群，须核验证件', 2500, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(9, '成人票', 200.00, '景区大门票，演示价格，以现场公示为准', 2000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(9, '优惠票', 100.00, '学生及符合条件的优惠人群，须核验证件', 600, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(10, '成人票', 35.00, '景区大门票，演示价格，以现场公示为准', 6000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(10, '优惠票', 17.50, '学生及符合条件的优惠人群，须核验证件', 2500, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(11, '成人票', 115.00, '景区大门票，演示价格，以现场公示为准', 6000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(11, '优惠票', 57.50, '学生及符合条件的优惠人群，须核验证件', 2500, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(12, '免票预约', 0.00, '开放区域免大门票，演示环境仍可生成预约订单', 20000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(12, '观光体验票', 60.00, '区间车、游船或讲解等体验项目，价格为演示值', 3000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(13, '成人票', 90.00, '景区大门票，演示价格，以现场公示为准', 6000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(13, '优惠票', 45.00, '学生及符合条件的优惠人群，须核验证件', 2500, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(14, '免票预约', 0.00, '开放区域免大门票，演示环境仍可生成预约订单', 20000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(14, '观光体验票', 60.00, '区间车、游船或讲解等体验项目，价格为演示值', 3000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(15, '成人票', 80.00, '景区大门票，演示价格，以现场公示为准', 6000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(15, '优惠票', 40.00, '学生及符合条件的优惠人群，须核验证件', 2500, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(16, '成人票', 160.00, '景区大门票，演示价格，以现场公示为准', 6000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(16, '优惠票', 80.00, '学生及符合条件的优惠人群，须核验证件', 2500, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(17, '成人票', 80.00, '景区大门票，演示价格，以现场公示为准', 6000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(17, '优惠票', 40.00, '学生及符合条件的优惠人群，须核验证件', 2500, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(18, '免票预约', 0.00, '开放区域免大门票，演示环境仍可生成预约订单', 20000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(18, '观光体验票', 60.00, '区间车、游船或讲解等体验项目，价格为演示值', 3000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(19, '成人票', 238.00, '景区大门票，演示价格，以现场公示为准', 800, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(19, '优惠票', 119.00, '学生及符合条件的优惠人群，须核验证件', 300, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(20, '免票预约', 0.00, '开放区域免大门票，演示环境仍可生成预约订单', 20000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(20, '观光体验票', 60.00, '区间车、游船或讲解等体验项目，价格为演示值', 3000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(21, '免票预约', 0.00, '开放区域免大门票，演示环境仍可生成预约订单', 20000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(21, '观光体验票', 60.00, '区间车、游船或讲解等体验项目，价格为演示值', 3000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(22, '成人票', 74.00, '景区大门票，演示价格，以现场公示为准', 6000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(22, '优惠票', 37.00, '学生及符合条件的优惠人群，须核验证件', 2500, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(23, '成人票', 160.00, '景区大门票，演示价格，以现场公示为准', 6000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(23, '优惠票', 80.00, '学生及符合条件的优惠人群，须核验证件', 2500, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(24, '成人票', 125.00, '景区大门票，演示价格，以现场公示为准', 6000, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY)),
(24, '优惠票', 62.50, '学生及符合条件的优惠人群，须核验证件', 2500, 1, DATE_SUB(TIMESTAMP(CURDATE(), '11:00:00'), INTERVAL 20 DAY));
INSERT INTO route (title, days, cover_url, summary, detail, price_from, status, created_at, updated_at) VALUES
('京华四日 · 皇城与长城', 4, '/media/images/gugong_thumb.webp', '用四天把北京的中轴线和八达岭走完，按预约场次排，不赶日出团。', '适合第一次到北京。路线价格为交通与住宿的参考，不含景区大门票，门票请在本站按日期另约。
第1天故宫中轴线；第2天东六宫；第3-4天八达岭往返。', 1280.00, 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:00:00'), INTERVAL 17 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:00:00'), INTERVAL 3 DAY)),
('江南烟雨五日', 5, '/media/images/xihu_thumb.webp', '杭州西湖、上海外滩和苏州拙政园连成一条慢路线。', '第1-2天西湖环湖；第3天外滩，建议留到晚上；第4-5天苏州拙政园，并留半天给平江路。
城际交通以高铁为主，演示参考价不含门票。', 1680.00, 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:00:00'), INTERVAL 16 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:00:00'), INTERVAL 3 DAY)),
('徽杭名山四日', 4, '/media/images/huangshan_thumb.webp', '先把黄山的前后山走完，再降到杭州西湖收尾，体力和风景都有落差。', '黄山建议住山上一个晚上，才能等云海。第四天到杭州只安排环湖，不再加登山。', 1520.00, 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:00:00'), INTERVAL 15 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:00:00'), INTERVAL 3 DAY)),
('湘黔山水四日', 4, '/media/images/zhangjiajie_thumb.webp', '武陵源的峰林和黄果树的水雾，是西南两条完全不同的自然景观。', '张家界安排两天，不要把袁家界和金鞭溪挤在同一个上午。后两天转场安顺看瀑布。', 1460.00, 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:00:00'), INTERVAL 14 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:00:00'), INTERVAL 3 DAY)),
('川西秘境四日', 4, '/media/images/jiuzhaigou_thumb.webp', '九寨沟的水和峨眉山的云海放在一次川西行程里，中间需要留出交通。', '九寨沟必须按预约日进入。峨眉若只有一天，优先金顶，不要同时强求全山寺庙。', 1960.00, 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:00:00'), INTERVAL 13 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:00:00'), INTERVAL 3 DAY)),
('陕甘丝路五日', 5, '/media/images/bingmayong_thumb.webp', '从兵马俑到张掖丹霞，再到敦煌莫高窟，把秦的地下军阵和丝路风光连起来。', '西安到敦煌距离远，演示行程默认含一段航空或过夜列车。莫高窟单独预约，不要与抵达同一小时叠在一起。', 2280.00, 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:00:00'), INTERVAL 12 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:00:00'), INTERVAL 3 DAY)),
('山海四日 · 鼓浪屿与亚龙湾', 4, '/media/images/gulangyu_thumb.webp', '厦门鼓浪屿和三亚亚龙湾，一段步行的岛，一段敞开的湾。', '前两天不要排太满，鼓浪屿适合步行。后两天把亚龙湾留在白天，傍晚看海就够了。', 1680.00, 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:00:00'), INTERVAL 11 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:00:00'), INTERVAL 3 DAY)),
('滇桂山水三日', 3, '/media/images/lijiang_gucheng_thumb.webp', '丽江古城负责走路，桂林漓江负责坐船，中间是一段航班或高铁。', '古城维护费按景区规则另行登记。漓江竹筏尽量排在上午。', 1460.00, 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:00:00'), INTERVAL 10 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:00:00'), INTERVAL 3 DAY)),
('丝路与雪域四日', 4, '/media/images/mogaoku_thumb.webp', '敦煌莫高窟和布达拉宫分属两段高原行程，适合已经有过高海拔经验的人。', '演示路线含敦煌与拉萨之间的航空。落地拉萨的第一天不进布达拉宫，只适应海拔。', 2680.00, 1, DATE_SUB(TIMESTAMP(CURDATE(), '09:00:00'), INTERVAL 9 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:00:00'), INTERVAL 3 DAY));
INSERT INTO route_spot (route_id, spot_id, day_no, sort_order, stay_note) VALUES
(1, 1, 1, 1, '中轴线与三大殿，预约上午场'),
(1, 1, 2, 2, '东六宫与景山回望屋顶'),
(1, 2, 3, 3, '北城往返，预留下山时间'),
(1, 2, 4, 4, '南城补看，下午返城'),
(2, 3, 1, 1, '白堤、苏堤与雷峰塔，按体力取舍'),
(2, 3, 2, 2, '灵隐、龙井一带，仍以西湖为落脚'),
(2, 14, 3, 3, '白天看万国建筑，晚上看江对岸'),
(2, 13, 4, 4, '上午入园，避开旅行团'),
(2, 13, 5, 5, '补看园内西侧，下午返程'),
(3, 4, 1, 1, '云谷索道上山，住光明顶或西海附近'),
(3, 4, 2, 2, '日出与西海大峡谷'),
(3, 4, 3, 3, '玉屏索道下山，汤口休整'),
(3, 3, 4, 4, '环湖步行，作为下山后的缓冲'),
(4, 5, 1, 1, '金鞭溪徒步'),
(4, 5, 2, 2, '袁家界与天子山'),
(4, 23, 3, 3, '大瀑布观景台'),
(4, 23, 4, 4, '天星桥，量力而行'),
(5, 6, 1, 1, '树正、诺日朗、五花海'),
(5, 6, 2, 2, '长海、珍珠滩，按体力回头'),
(5, 17, 3, 3, '转场乐山，先看大佛'),
(5, 16, 4, 4, '索道上金顶'),
(6, 7, 1, 1, '一号坑、三号坑与铜车马'),
(6, 22, 2, 2, '彩色丘陵，尽量赶在黄昏'),
(6, 22, 3, 3, '清晨补看七彩一带，下午转场'),
(6, 19, 4, 4, '数字展示中心与预约洞窟'),
(6, 19, 5, 5, '鸣沙山方向自由活动，不重复进窟'),
(7, 10, 1, 1, '轮渡上岛，日光岩'),
(7, 10, 2, 2, '内厝澳与环岛路'),
(7, 20, 3, 3, '白天在湾里'),
(7, 20, 4, 4, '清晨再走一次沙滩，下午返程'),
(8, 12, 1, 1, '四方街、木府'),
(8, 12, 2, 2, '狮子山与安静的巷子'),
(8, 8, 3, 3, '阳朔段竹筏或游船'),
(9, 19, 1, 1, '数字展示中心与预约洞窟'),
(9, 19, 2, 2, '补看展示，不重复进同一组洞窟'),
(9, 9, 3, 3, '抵拉萨，不安排登宫'),
(9, 9, 4, 4, '按预约时段参观');
INSERT INTO travel_note (user_id, spot_id, title, cover_url, content, status, reject_reason, like_count, view_count, created_at, updated_at) VALUES
(2, 3, '雨天的西湖比晴天更像一幅未干的画', '/media/images/xihu_thumb.webp', '早上下了雨，白堤上的人比我想的少。水面没有那种明信片式的蓝，反而发灰，远处的雷峰塔像被橡皮擦过一遍。

我从断桥走到平湖秋月，再折回锦带桥。雨衣的帽子一直滑下来，但这比晴天被人群推着走舒服。中午在湖滨随便吃了面，下午苏堤的风把云吹开了一条缝，湖面才忽然亮起来。

如果只有一天，我仍然建议把走路放在船上：船会告诉你湖有多大，路会告诉你湖有多近。门票本身是免费的，游船另算，不用为了打卡把所有收费点买全。', 'APPROVED', NULL, 5, 97, DATE_SUB(TIMESTAMP(CURDATE(), '15:20:00'), INTERVAL 7 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '15:20:00'), INTERVAL 7 DAY)),
(3, 2, '八达岭不要只走到好汉坡', '/media/images/badaling_thumb.webp', '好汉坡的牌坊前面永远在拍照，真正值得继续的是北城再往上的那几段。风会变大，城墙也更窄，但山的层次终于露出来。

我坐缆车上去，步行下来。下行的时候膝盖比上行更累，所以不要把时间卡死。春秋的八达岭比夏天干净，冬天则要看积雪是否封路。

门票不贵，贵的是来回的时间。从市区出发至少留出一整天，不要和故宫排在同一天。', 'APPROVED', NULL, 4, 114, DATE_SUB(TIMESTAMP(CURDATE(), '15:20:00'), INTERVAL 8 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '15:20:00'), INTERVAL 8 DAY)),
(4, 1, '故宫闭馆日前一天的中轴线', '/media/images/gugong_thumb.webp', '周一闭馆，所以我把故宫放在周日。上午场的人已经很多，但中轴线一旦走起来，节奏就由自己掌握。太和殿前的空地比想象中更大，午门到神武门的距离也比地图看起来长。

我没有进珍宝馆，把时间留给了东西六宫之间的夹道。那里的砖和窗比三大殿更接近人的尺度。出来时从景山后门往上看了一眼，整座宫殿的黄色屋顶才变成一张完整的图。

预约按证件，不要临时换同行的人。讲解器值得租，比跟着扩音器走更安静。', 'APPROVED', NULL, 6, 131, DATE_SUB(TIMESTAMP(CURDATE(), '15:20:00'), INTERVAL 9 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '15:20:00'), INTERVAL 9 DAY)),
(5, 6, '九寨沟的水不是一种蓝', '/media/images/jiuzhaigou_thumb.webp', '五花海在中午偏绿，到了三点又透出一点紫。导游说是矿物质和光线，我更愿意相信是水底的树干在作怪。珍珠滩的水很浅，声音却很大。

沟里全靠观光车。不要试图从树正走到长海，那不是散步距离。诺日朗用午餐人最多，自带一点干粮会从容。

秋季是最挤的季节，预约成功才算数。我的订单日期比我想的早一天，幸好没有订错返程。', 'APPROVED', NULL, 4, 148, DATE_SUB(TIMESTAMP(CURDATE(), '15:20:00'), INTERVAL 10 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '15:20:00'), INTERVAL 10 DAY)),
(6, 5, '张家界金鞭溪适合把脚步放慢', '/media/images/zhangjiajie_thumb.webp', '金鞭溪的水不深，路也平，峰林就立在溪的两边。这里不适合赶时间。我用了将近三个小时走完常用的那段，中间在溪石上坐了两次。

下午上袁家界，风景突然从溪谷变成台地，人也会突然变多。百龙天梯省时间，但要单独买票。如果只能选一个，我选上午的溪和下午的台地，而不是两个都跑马。

山上的雨说来就来，背包里的薄外套最后是全天最有用的东西。', 'APPROVED', NULL, 3, 165, DATE_SUB(TIMESTAMP(CURDATE(), '15:20:00'), INTERVAL 11 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '15:20:00'), INTERVAL 11 DAY)),
(7, 13, '拙政园的白墙把光留住了', '/media/images/zhuozhengyuan_thumb.webp', '进门以后先到远香堂，对面就是池子。苏州园林的好不在高，而在你每转一次身，画面的边界都被墙重新裁过。

我在见山楼坐了一会儿。导游团过去之后，池子里的倒影才重新连上。园子不大，但不要用一小时把它走完，那会只剩下走廊。

工作日上午最合适。联票里的博物馆可以用剩下的体力，不必强求。', 'APPROVED', NULL, 3, 182, DATE_SUB(TIMESTAMP(CURDATE(), '15:20:00'), INTERVAL 12 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '15:20:00'), INTERVAL 12 DAY)),
(2, 10, '鼓浪屿绕开龙头路之后', '/media/images/gulangyu_thumb.webp', '轮渡十五分钟就到了。龙头路很热闹，钢琴博物馆也值得看，但岛屿真正好走的是往内厝澳去的那些坡。房子的颜色开始变淡，还能听见操场的哨子。

环岛一圈用不了一整天。日光岩可以上去，风大，鞋子要比漂亮更重要。岛上没有汽车，行李箱是错误的选择。

轮渡票和景点票分开。如果不进收费点，只是走路和坐在海边，这一天已经完整。', 'APPROVED', NULL, 4, 199, DATE_SUB(TIMESTAMP(CURDATE(), '15:20:00'), INTERVAL 13 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '15:20:00'), INTERVAL 13 DAY)),
(3, 19, '莫高窟的预约窟要提前看讲解', '/media/images/mogaoku_thumb.webp', '数字展示中心的电影把壁画放大了，进窟以后反而要靠刚才的记忆。实体洞窟光线很暗，停留时间也短，没有提前了解就只剩下看一个洞口。

讲解员的节奏固定，中间不能拍照。我把问题记在本子上，出来再问。敦煌的太阳很烈，从展示中心到窟区的摆渡车上就应该把水喝完。

预约时段不要迟到。迟到不是排队的问题，而是这一组洞窟可能已经开始，你进不去。', 'APPROVED', NULL, 5, 216, DATE_SUB(TIMESTAMP(CURDATE(), '15:20:00'), INTERVAL 14 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '15:20:00'), INTERVAL 14 DAY)),
(2, 24, '平遥南大街的晚上还没写完', '/media/images/pingyao_thumb.webp', '这篇还在整理。城墙上下来以后，我改走南大街后面的巷子，叫卖声被墙隔开了。日升昌只在门口看了一眼，没有再排队。

想写清楚县衙前那棵树的光线，但照片还没挑。先提交给编辑看看结构是否成立。', 'PENDING', NULL, 0, 233, DATE_SUB(TIMESTAMP(CURDATE(), '15:20:00'), INTERVAL 2 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '15:20:00'), INTERVAL 1 DAY)),
(4, 4, '黄山看云海前请先读天气', '/media/images/huangshan_thumb.webp', '朋友临时约山上过夜，我劝他先看第二天的风。光明顶不是想来就来，索道也会因风停开。下山的末班比想象中早。

这篇还缺我自己的上山记录，先作为草稿送审。如果通过，我会补上西海的时间表。', 'PENDING', NULL, 0, 250, DATE_SUB(TIMESTAMP(CURDATE(), '15:20:00'), INTERVAL 2 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '15:20:00'), INTERVAL 1 DAY));
INSERT INTO note_like (note_id, user_id, created_at) VALUES
(1, 3, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 6 DAY)),
(1, 5, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 6 DAY)),
(1, 7, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 6 DAY)),
(1, 9, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 6 DAY)),
(1, 15, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 6 DAY)),
(2, 2, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 7 DAY)),
(2, 4, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 7 DAY)),
(2, 8, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 7 DAY)),
(2, 10, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 7 DAY)),
(3, 2, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 8 DAY)),
(3, 3, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 8 DAY)),
(3, 5, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 8 DAY)),
(3, 6, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 8 DAY)),
(3, 11, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 8 DAY)),
(3, 12, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 8 DAY)),
(4, 6, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 9 DAY)),
(4, 2, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 9 DAY)),
(4, 7, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 9 DAY)),
(4, 13, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 9 DAY)),
(5, 4, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 10 DAY)),
(5, 5, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 10 DAY)),
(5, 14, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 10 DAY)),
(6, 9, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 11 DAY)),
(6, 2, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 11 DAY)),
(6, 16, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 11 DAY)),
(7, 10, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 12 DAY)),
(7, 3, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 12 DAY)),
(7, 7, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 12 DAY)),
(7, 15, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 12 DAY)),
(8, 2, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 13 DAY)),
(8, 4, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 13 DAY)),
(8, 11, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 13 DAY)),
(8, 12, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 13 DAY)),
(8, 5, DATE_SUB(TIMESTAMP(CURDATE(), '18:00:00'), INTERVAL 13 DAY));
INSERT INTO comment (user_id, target_type, target_id, content, status, created_at) VALUES
(3, 'NOTE', 1, '雨天的白堤确实更空。我上次走苏堤，伞都快被风收走。', 'VISIBLE', DATE_SUB(TIMESTAMP(CURDATE(), '12:10:00'), INTERVAL 1 DAY)),
(5, 'NOTE', 1, '赞同把船和路分开写，我之前一次买太全，反而累。', 'VISIBLE', DATE_SUB(TIMESTAMP(CURDATE(), '12:10:00'), INTERVAL 2 DAY)),
(7, 'NOTE', 2, '北城的风比南城大一截，帽子要有绳子。', 'VISIBLE', DATE_SUB(TIMESTAMP(CURDATE(), '12:10:00'), INTERVAL 3 DAY)),
(2, 'NOTE', 3, '景山回头看屋顶那段，我下次也要留在最后。', 'VISIBLE', DATE_SUB(TIMESTAMP(CURDATE(), '12:10:00'), INTERVAL 4 DAY)),
(6, 'NOTE', 4, '五花海下午的颜色我至今没法用一种蓝描述。', 'VISIBLE', DATE_SUB(TIMESTAMP(CURDATE(), '12:10:00'), INTERVAL 5 DAY)),
(4, 'NOTE', 5, '金鞭溪的平路很友好，适合带父母，袁家界就不必了。', 'VISIBLE', DATE_SUB(TIMESTAMP(CURDATE(), '12:10:00'), INTERVAL 6 DAY)),
(9, 'NOTE', 6, '见山楼那一会儿最值得，人一散倒影就回来了。', 'VISIBLE', DATE_SUB(TIMESTAMP(CURDATE(), '12:10:00'), INTERVAL 7 DAY)),
(10, 'NOTE', 7, '内厝澳的坡很好走，龙头路的小吃可以点到为止。', 'VISIBLE', DATE_SUB(TIMESTAMP(CURDATE(), '12:10:00'), INTERVAL 8 DAY)),
(8, 'SPOT', 1, '周日上午场已经要提前很久预约，中轴线的距离比地图长。', 'VISIBLE', DATE_SUB(TIMESTAMP(CURDATE(), '12:10:00'), INTERVAL 0 DAY)),
(5, 'SPOT', 1, '讲解器比扩音器安静，东六宫的夹道值得慢慢看。', 'VISIBLE', DATE_SUB(TIMESTAMP(CURDATE(), '12:10:00'), INTERVAL 1 DAY)),
(7, 'SPOT', 3, '清晨的断桥人少，游船建议放到下午风小的时候。', 'VISIBLE', DATE_SUB(TIMESTAMP(CURDATE(), '12:10:00'), INTERVAL 2 DAY)),
(6, 'SPOT', 6, '观光车要跟上节奏，长海那一站不要迟到。', 'VISIBLE', DATE_SUB(TIMESTAMP(CURDATE(), '12:10:00'), INTERVAL 3 DAY)),
(15, 'SPOT', 7, '一号坑的军阵比照片更震撼，铜车马展厅别跳过。', 'VISIBLE', DATE_SUB(TIMESTAMP(CURDATE(), '12:10:00'), INTERVAL 4 DAY)),
(14, 'SPOT', 5, '金鞭溪可以走很久，百龙天梯的票记得单独买。', 'VISIBLE', DATE_SUB(TIMESTAMP(CURDATE(), '12:10:00'), INTERVAL 5 DAY)),
(13, 'SPOT', 12, '四方街晚上很热闹，想安静就往狮子山后面走。', 'VISIBLE', DATE_SUB(TIMESTAMP(CURDATE(), '12:10:00'), INTERVAL 6 DAY)),
(11, 'SPOT', 19, '数字电影先看再进窟，不然暗光里会错过细节。', 'VISIBLE', DATE_SUB(TIMESTAMP(CURDATE(), '12:10:00'), INTERVAL 7 DAY)),
(12, 'SPOT', 13, '工作日上午进园，远香堂对面的池子最适合发呆。', 'VISIBLE', DATE_SUB(TIMESTAMP(CURDATE(), '12:10:00'), INTERVAL 8 DAY)),
(16, 'SPOT', 2, '从市区过去要留够一天，不建议和市区景点叠在一起。', 'VISIBLE', DATE_SUB(TIMESTAMP(CURDATE(), '12:10:00'), INTERVAL 0 DAY)),
(9, 'SPOT', 4, '山上比市区冷，六月我也穿了外套。索道尽量进出不走同一条。', 'VISIBLE', DATE_SUB(TIMESTAMP(CURDATE(), '12:10:00'), INTERVAL 1 DAY)),
(10, 'SPOT', 9, '落地当天不要安排参观，预约时段一定要守时。', 'VISIBLE', DATE_SUB(TIMESTAMP(CURDATE(), '12:10:00'), INTERVAL 2 DAY));
INSERT INTO favorite (user_id, target_type, target_id, created_at) VALUES
(2, 'SPOT', 1, DATE_SUB(TIMESTAMP(CURDATE(), '20:00:00'), INTERVAL 4 DAY)),
(2, 'SPOT', 3, DATE_SUB(TIMESTAMP(CURDATE(), '20:00:00'), INTERVAL 4 DAY)),
(2, 'SPOT', 6, DATE_SUB(TIMESTAMP(CURDATE(), '20:00:00'), INTERVAL 4 DAY)),
(2, 'SPOT', 12, DATE_SUB(TIMESTAMP(CURDATE(), '20:00:00'), INTERVAL 4 DAY)),
(2, 'ROUTE', 1, DATE_SUB(TIMESTAMP(CURDATE(), '20:00:00'), INTERVAL 4 DAY)),
(2, 'NOTE', 1, DATE_SUB(TIMESTAMP(CURDATE(), '20:00:00'), INTERVAL 4 DAY)),
(3, 'SPOT', 19, DATE_SUB(TIMESTAMP(CURDATE(), '20:00:00'), INTERVAL 4 DAY)),
(3, 'SPOT', 2, DATE_SUB(TIMESTAMP(CURDATE(), '20:00:00'), INTERVAL 4 DAY)),
(4, 'SPOT', 4, DATE_SUB(TIMESTAMP(CURDATE(), '20:00:00'), INTERVAL 4 DAY)),
(5, 'NOTE', 4, DATE_SUB(TIMESTAMP(CURDATE(), '20:00:00'), INTERVAL 4 DAY)),
(7, 'ROUTE', 2, DATE_SUB(TIMESTAMP(CURDATE(), '20:00:00'), INTERVAL 4 DAY)),
(6, 'SPOT', 5, DATE_SUB(TIMESTAMP(CURDATE(), '20:00:00'), INTERVAL 4 DAY));
INSERT INTO news (title, cover_url, summary, content, status, published_at, created_at, updated_at) VALUES
('热门景区继续实行分时预约', '/media/images/banner_1.webp', '十一前后及周末，故宫、九寨沟、莫高窟等景区按日放票。请先注册并在门票页选择日期，订单以提交成功为准。', '为了避免现场排队，山河纪演示环境中的热门景点都要求先选日期和票种。

同一证件在同一游玩日只保留一笔有效订单。取消订单会把库存退回，但请尽量提前操作。

本公告为课程演示文案，实际出行请以景区官方公告为准。', 1, DATE_SUB(TIMESTAMP(CURDATE(), '08:30:00'), INTERVAL 1 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '08:30:00'), INTERVAL 1 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '08:30:00'), INTERVAL 1 DAY)),
('关于演示环境与票价的说明', '/media/images/banner_2.webp', '本站票价、开放时间和库存均为课程设计数据，不代表景区实时公示。', '山河纪是 Web 编程实践课程的综合项目，用于演示前后端分离、预约、游记审核和数据统计。

景点介绍与图片来自随项目提供的媒体包，照片为 Wikimedia Commons 上的自由授权作品，作者和协议写在每张图下方，汇总见网站《素材署名》。介绍视频只保存地址，不把视频文件放进仓库。

请勿将演示订单用于真实出行。', 1, DATE_SUB(TIMESTAMP(CURDATE(), '08:30:00'), INTERVAL 2 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '08:30:00'), INTERVAL 2 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '08:30:00'), INTERVAL 2 DAY)),
('九寨沟秋季彩林观赏提示', '/media/images/banner_3.webp', '秋季是九寨沟最繁忙的季节，观光车班次会加密，仍建议按预约时段入沟。', '彩林通常出现在十月前后，具体变色进度每年不同。沟内温差大，薄外套比厚毛衣更灵活。

诺日朗服务点午餐排队较长，可自带简单食物。不要离开栈道靠近钙化堤坝。', 1, DATE_SUB(TIMESTAMP(CURDATE(), '08:30:00'), INTERVAL 3 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '08:30:00'), INTERVAL 3 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '08:30:00'), INTERVAL 3 DAY)),
('故宫博物院周一闭馆提醒', '/media/images/banner_4.webp', '除法定节假日外，故宫博物院周一闭馆。请不要把行程死死卡在周一。', '如果行程里只有一个工作日可以安排故宫，请先确认那天不是周一。珍宝馆与钟表馆门票单独计算。

演示环境里的成人票、学生票仅用于下单流程，不能作为入馆凭证。', 1, DATE_SUB(TIMESTAMP(CURDATE(), '08:30:00'), INTERVAL 4 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '08:30:00'), INTERVAL 4 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '08:30:00'), INTERVAL 4 DAY)),
('新路线「陕甘丝路五日」已发布', '/media/images/banner_5.webp', '兵马俑、张掖丹霞与莫高窟被串到同一条演示路线中，交通跨度较大，适合作为课程展示数据。', '这条路线的参考价不含大门票。莫高窟需要单独预约洞窟，丹霞的最佳光线多在傍晚。

你可以从推荐路线页进入，再跳转到每个景点分别下单。', 1, DATE_SUB(TIMESTAMP(CURDATE(), '08:30:00'), INTERVAL 5 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '08:30:00'), INTERVAL 5 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '08:30:00'), INTERVAL 5 DAY)),
('文明参观倡议', '/media/images/banner_1.webp', '石窟内不拍照，长城上不攀爬未开放段落，园林里不踩草坪。', '评论和游记请使用文明用语。含有广告、人身攻击的内容会被管理员隐藏或驳回。

演示账号仅供课程验收，请不要在游记中留下真实的证件号码或家庭住址。', 1, DATE_SUB(TIMESTAMP(CURDATE(), '08:30:00'), INTERVAL 6 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '08:30:00'), INTERVAL 6 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '08:30:00'), INTERVAL 6 DAY));
INSERT INTO banner (title, subtitle, image_url, link_url, sort_order, status, created_at) VALUES
('山脊上的长城', '八达岭北城，风比好汉坡更大', '/media/images/banner_1.webp', '/spots/2', 1, 1, DATE_SUB(TIMESTAMP(CURDATE(), '08:00:00'), INTERVAL 12 DAY)),
('峰林与金鞭溪', '张家界适合把脚步放慢', '/media/images/banner_2.webp', '/spots/5', 2, 1, DATE_SUB(TIMESTAMP(CURDATE(), '08:00:00'), INTERVAL 12 DAY)),
('九寨沟的水会变色', '先预约，再把一天交给观光车', '/media/images/banner_3.webp', '/spots/6', 3, 1, DATE_SUB(TIMESTAMP(CURDATE(), '08:00:00'), INTERVAL 12 DAY)),
('张掖的彩色丘陵', '七彩丹霞，黄昏最合适', '/media/images/banner_4.webp', '/spots/22', 4, 1, DATE_SUB(TIMESTAMP(CURDATE(), '08:00:00'), INTERVAL 12 DAY)),
('外滩的江风', '浦西的楼，和浦东的灯', '/media/images/banner_5.webp', '/spots/14', 5, 1, DATE_SUB(TIMESTAMP(CURDATE(), '08:00:00'), INTERVAL 12 DAY));
INSERT INTO booking_order (order_no, user_id, spot_id, ticket_type_id, visit_date, quantity, unit_price, total_amount, contact_name, contact_phone, status, remark, created_at, updated_at) VALUES
('SH00000001', 12, 12, 23, DATE_ADD(CURDATE(), INTERVAL 8 DAY), 1, 0.00, 0.00, '顾七', '13800001011', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 13 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 13 DAY)),
('SH00000002', 5, 5, 9, DATE_ADD(CURDATE(), INTERVAL 7 DAY), 3, 225.00, 675.00, '苏晚晴', '13800001004', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 13 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 13 DAY)),
('SH00000003', 5, 4, 7, DATE_SUB(CURDATE(), INTERVAL 11 DAY), 3, 190.00, 570.00, '苏晚晴', '13800001004', 'COMPLETED', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 12 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 12 DAY)),
('SH00000004', 5, 6, 11, DATE_ADD(CURDATE(), INTERVAL 1 DAY), 1, 160.00, 160.00, '苏晚晴', '13800001004', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 12 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 12 DAY)),
('SH00000005', 11, 3, 5, DATE_ADD(CURDATE(), INTERVAL 2 DAY), 3, 0.00, 0.00, '薛谣', '13800001010', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 12 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 12 DAY)),
('SH00000006', 2, 6, 11, DATE_ADD(CURDATE(), INTERVAL 11 DAY), 1, 160.00, 160.00, '林晓晚', '13800001001', 'CANCELLED', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 11 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 11 DAY)),
('SH00000007', 5, 17, 34, DATE_ADD(CURDATE(), INTERVAL 6 DAY), 2, 40.00, 80.00, '苏晚晴', '13800001004', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 11 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 11 DAY)),
('SH00000008', 8, 20, 40, DATE_ADD(CURDATE(), INTERVAL 2 DAY), 1, 60.00, 60.00, '刘川', '13800001007', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 10 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 10 DAY)),
('SH00000009', 4, 13, 26, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 1, 45.00, 45.00, '陈一楠', '13800001003', 'COMPLETED', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 10 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 10 DAY)),
('SH00000010', 7, 3, 5, DATE_ADD(CURDATE(), INTERVAL 3 DAY), 1, 0.00, 0.00, '何曼', '13800001006', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 10 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 10 DAY)),
('SH00000011', 8, 5, 9, DATE_ADD(CURDATE(), INTERVAL 3 DAY), 2, 225.00, 450.00, '刘川', '13800001007', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '14:05:00'), INTERVAL 10 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '14:05:00'), INTERVAL 10 DAY)),
('SH00000012', 13, 15, 30, DATE_ADD(CURDATE(), INTERVAL 13 DAY), 1, 40.00, 40.00, '潘晓', '13800001012', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 9 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 9 DAY)),
('SH00000013', 2, 16, 31, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 1, 160.00, 160.00, '林晓晚', '13800001001', 'COMPLETED', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 9 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 9 DAY)),
('SH00000014', 6, 22, 43, DATE_SUB(CURDATE(), INTERVAL 0 DAY), 3, 74.00, 222.00, '赵北辰', '13800001005', 'COMPLETED', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 9 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 9 DAY)),
('SH00000015', 15, 4, 7, DATE_ADD(CURDATE(), INTERVAL 10 DAY), 1, 190.00, 190.00, '江疏', '13800001014', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 8 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 8 DAY)),
('SH00000016', 11, 21, 41, DATE_SUB(CURDATE(), INTERVAL 0 DAY), 1, 0.00, 0.00, '薛谣', '13800001010', 'COMPLETED', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 8 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 8 DAY)),
('SH00000017', 8, 17, 33, DATE_ADD(CURDATE(), INTERVAL 11 DAY), 1, 80.00, 80.00, '刘川', '13800001007', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 8 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 8 DAY)),
('SH00000018', 12, 7, 13, DATE_SUB(CURDATE(), INTERVAL 7 DAY), 2, 120.00, 240.00, '顾七', '13800001011', 'COMPLETED', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '14:05:00'), INTERVAL 8 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '14:05:00'), INTERVAL 8 DAY)),
('SH00000019', 6, 2, 3, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 2, 40.00, 80.00, '赵北辰', '13800001005', 'COMPLETED', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '15:33:00'), INTERVAL 8 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '15:33:00'), INTERVAL 8 DAY)),
('SH00000020', 13, 12, 23, DATE_ADD(CURDATE(), INTERVAL 17 DAY), 3, 0.00, 0.00, '潘晓', '13800001012', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 7 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 7 DAY)),
('SH00000021', 6, 24, 47, DATE_ADD(CURDATE(), INTERVAL 15 DAY), 1, 125.00, 125.00, '赵北辰', '13800001005', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 7 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 7 DAY)),
('SH00000022', 13, 10, 19, DATE_SUB(CURDATE(), INTERVAL 4 DAY), 3, 35.00, 105.00, '潘晓', '13800001012', 'COMPLETED', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 7 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 7 DAY)),
('SH00000023', 5, 6, 12, DATE_ADD(CURDATE(), INTERVAL 18 DAY), 2, 80.00, 160.00, '苏晚晴', '13800001004', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '14:05:00'), INTERVAL 7 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '14:05:00'), INTERVAL 7 DAY)),
('SH00000024', 4, 6, 11, DATE_SUB(CURDATE(), INTERVAL 4 DAY), 3, 160.00, 480.00, '陈一楠', '13800001003', 'COMPLETED', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 6 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 6 DAY)),
('SH00000025', 8, 17, 33, DATE_ADD(CURDATE(), INTERVAL 11 DAY), 1, 80.00, 80.00, '刘川', '13800001007', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 6 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 6 DAY)),
('SH00000026', 14, 1, 1, DATE_ADD(CURDATE(), INTERVAL 7 DAY), 1, 60.00, 60.00, '冯念', '13800001013', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 6 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 6 DAY)),
('SH00000027', 2, 2, 3, DATE_ADD(CURDATE(), INTERVAL 15 DAY), 2, 40.00, 80.00, '林晓晚', '13800001001', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '14:05:00'), INTERVAL 6 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '14:05:00'), INTERVAL 6 DAY)),
('SH00000028', 3, 18, 35, DATE_ADD(CURDATE(), INTERVAL 7 DAY), 1, 0.00, 0.00, '周予安', '13800001002', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '15:33:00'), INTERVAL 6 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '15:33:00'), INTERVAL 6 DAY)),
('SH00000029', 16, 19, 38, DATE_ADD(CURDATE(), INTERVAL 9 DAY), 1, 119.00, 119.00, '罗白', '13800001015', 'CANCELLED', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '16:48:00'), INTERVAL 6 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '16:48:00'), INTERVAL 6 DAY)),
('SH00000030', 5, 6, 11, DATE_ADD(CURDATE(), INTERVAL 13 DAY), 2, 160.00, 320.00, '苏晚晴', '13800001004', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 5 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 5 DAY)),
('SH00000031', 7, 20, 40, DATE_ADD(CURDATE(), INTERVAL 15 DAY), 1, 60.00, 60.00, '何曼', '13800001006', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 5 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 5 DAY)),
('SH00000032', 10, 5, 9, DATE_ADD(CURDATE(), INTERVAL 6 DAY), 1, 225.00, 225.00, '毛野', '13800001009', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 5 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 5 DAY)),
('SH00000033', 13, 16, 31, DATE_ADD(CURDATE(), INTERVAL 2 DAY), 2, 160.00, 320.00, '潘晓', '13800001012', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 4 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 4 DAY)),
('SH00000034', 11, 5, 9, DATE_ADD(CURDATE(), INTERVAL 5 DAY), 3, 225.00, 675.00, '薛谣', '13800001010', 'CANCELLED', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 4 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 4 DAY)),
('SH00000035', 8, 17, 33, DATE_ADD(CURDATE(), INTERVAL 17 DAY), 1, 80.00, 80.00, '刘川', '13800001007', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 4 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 4 DAY)),
('SH00000036', 16, 3, 6, DATE_ADD(CURDATE(), INTERVAL 15 DAY), 1, 60.00, 60.00, '罗白', '13800001015', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '14:05:00'), INTERVAL 4 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '14:05:00'), INTERVAL 4 DAY)),
('SH00000037', 2, 5, 9, DATE_ADD(CURDATE(), INTERVAL 10 DAY), 3, 225.00, 675.00, '林晓晚', '13800001001', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '15:33:00'), INTERVAL 4 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '15:33:00'), INTERVAL 4 DAY)),
('SH00000038', 4, 10, 19, DATE_ADD(CURDATE(), INTERVAL 12 DAY), 1, 35.00, 35.00, '陈一楠', '13800001003', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 3 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 3 DAY)),
('SH00000039', 14, 1, 1, DATE_ADD(CURDATE(), INTERVAL 10 DAY), 3, 60.00, 180.00, '冯念', '13800001013', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 3 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 3 DAY)),
('SH00000040', 4, 2, 3, DATE_ADD(CURDATE(), INTERVAL 5 DAY), 3, 40.00, 120.00, '陈一楠', '13800001003', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 3 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 3 DAY)),
('SH00000041', 13, 20, 39, DATE_ADD(CURDATE(), INTERVAL 10 DAY), 2, 0.00, 0.00, '潘晓', '13800001012', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '14:05:00'), INTERVAL 3 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '14:05:00'), INTERVAL 3 DAY)),
('SH00000042', 9, 4, 7, DATE_SUB(CURDATE(), INTERVAL 0 DAY), 3, 190.00, 570.00, '唐果', '13800001008', 'COMPLETED', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '15:33:00'), INTERVAL 3 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '15:33:00'), INTERVAL 3 DAY)),
('SH00000043', 5, 6, 11, DATE_ADD(CURDATE(), INTERVAL 12 DAY), 2, 160.00, 320.00, '苏晚晴', '13800001004', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '16:48:00'), INTERVAL 3 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '16:48:00'), INTERVAL 3 DAY)),
('SH00000044', 13, 6, 11, DATE_ADD(CURDATE(), INTERVAL 3 DAY), 1, 160.00, 160.00, '潘晓', '13800001012', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '19:12:00'), INTERVAL 3 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '19:12:00'), INTERVAL 3 DAY)),
('SH00000045', 11, 21, 42, DATE_ADD(CURDATE(), INTERVAL 16 DAY), 2, 60.00, 120.00, '薛谣', '13800001010', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 2 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 2 DAY)),
('SH00000046', 14, 23, 45, DATE_ADD(CURDATE(), INTERVAL 11 DAY), 2, 160.00, 320.00, '冯念', '13800001013', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 2 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 2 DAY)),
('SH00000047', 10, 2, 3, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 3, 40.00, 120.00, '毛野', '13800001009', 'COMPLETED', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 2 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 2 DAY)),
('SH00000048', 2, 4, 7, DATE_ADD(CURDATE(), INTERVAL 5 DAY), 3, 190.00, 570.00, '林晓晚', '13800001001', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '14:05:00'), INTERVAL 2 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '14:05:00'), INTERVAL 2 DAY)),
('SH00000049', 4, 3, 6, DATE_ADD(CURDATE(), INTERVAL 4 DAY), 2, 60.00, 120.00, '陈一楠', '13800001003', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 1 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 1 DAY)),
('SH00000050', 6, 4, 7, DATE_ADD(CURDATE(), INTERVAL 6 DAY), 3, 190.00, 570.00, '赵北辰', '13800001005', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 1 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 1 DAY)),
('SH00000051', 10, 7, 14, DATE_ADD(CURDATE(), INTERVAL 4 DAY), 3, 60.00, 180.00, '毛野', '13800001009', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 1 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 1 DAY)),
('SH00000052', 13, 12, 23, DATE_ADD(CURDATE(), INTERVAL 6 DAY), 3, 0.00, 0.00, '潘晓', '13800001012', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '14:05:00'), INTERVAL 1 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '14:05:00'), INTERVAL 1 DAY)),
('SH00000053', 7, 12, 23, DATE_ADD(CURDATE(), INTERVAL 12 DAY), 1, 0.00, 0.00, '何曼', '13800001006', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '15:33:00'), INTERVAL 1 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '15:33:00'), INTERVAL 1 DAY)),
('SH00000054', 16, 16, 31, DATE_ADD(CURDATE(), INTERVAL 9 DAY), 2, 160.00, 320.00, '罗白', '13800001015', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '16:48:00'), INTERVAL 1 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '16:48:00'), INTERVAL 1 DAY)),
('SH00000055', 12, 12, 23, DATE_ADD(CURDATE(), INTERVAL 3 DAY), 3, 0.00, 0.00, '顾七', '13800001011', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 0 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 0 DAY)),
('SH00000056', 2, 5, 9, DATE_ADD(CURDATE(), INTERVAL 3 DAY), 2, 225.00, 450.00, '林晓晚', '13800001001', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 0 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '10:42:00'), INTERVAL 0 DAY)),
('SH00000057', 14, 4, 7, DATE_ADD(CURDATE(), INTERVAL 2 DAY), 1, 190.00, 190.00, '冯念', '13800001013', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 0 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '11:26:00'), INTERVAL 0 DAY)),
('SH00000058', 7, 6, 12, DATE_ADD(CURDATE(), INTERVAL 8 DAY), 1, 80.00, 80.00, '何曼', '13800001006', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '14:05:00'), INTERVAL 0 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '14:05:00'), INTERVAL 0 DAY)),
('SH00000059', 9, 19, 38, DATE_ADD(CURDATE(), INTERVAL 2 DAY), 3, 119.00, 357.00, '唐果', '13800001008', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '15:33:00'), INTERVAL 0 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '15:33:00'), INTERVAL 0 DAY)),
('SH00000060', 12, 1, 1, DATE_ADD(CURDATE(), INTERVAL 6 DAY), 2, 60.00, 120.00, '顾七', '13800001011', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '16:48:00'), INTERVAL 0 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '16:48:00'), INTERVAL 0 DAY)),
('SH00000061', 6, 21, 42, DATE_ADD(CURDATE(), INTERVAL 15 DAY), 2, 60.00, 120.00, '赵北辰', '13800001005', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '19:12:00'), INTERVAL 0 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '19:12:00'), INTERVAL 0 DAY)),
('SH00000062', 11, 20, 39, DATE_ADD(CURDATE(), INTERVAL 10 DAY), 3, 0.00, 0.00, '薛谣', '13800001010', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 0 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:18:00'), INTERVAL 0 DAY)),
('SH00000063', 2, 1, 1, DATE_ADD(CURDATE(), INTERVAL 5 DAY), 2, 60.00, 120.00, '林晓晚', '13800001001', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '09:40:00'), INTERVAL 1 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '09:40:00'), INTERVAL 1 DAY)),
('SH00000064', 2, 3, 6, DATE_ADD(CURDATE(), INTERVAL 3 DAY), 1, 60.00, 60.00, '林晓晚', '13800001001', 'PENDING', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '11:15:00'), INTERVAL 0 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '11:15:00'), INTERVAL 0 DAY)),
('SH00000065', 2, 6, 11, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 1, 160.00, 160.00, '林晓晚', '13800001001', 'COMPLETED', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '13:20:00'), INTERVAL 6 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '13:20:00'), INTERVAL 6 DAY)),
('SH00000066', 2, 19, 37, DATE_ADD(CURDATE(), INTERVAL 9 DAY), 1, 238.00, 238.00, '林晓晚', '13800001001', 'CANCELLED', NULL, DATE_SUB(TIMESTAMP(CURDATE(), '17:05:00'), INTERVAL 3 DAY), DATE_SUB(TIMESTAMP(CURDATE(), '17:05:00'), INTERVAL 3 DAY));
SET FOREIGN_KEY_CHECKS = 1;
