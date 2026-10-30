# 山河纪 · 全国热门景点文旅门户

Web 编程实践课程设计：游客前台 + 管理后台。前端 Vue 3，后端 Spring Boot 3，数据库 MySQL 8。

## 演示账号

| 角色 | 用户名 | 密码 |
| --- | --- | --- |
| 管理员 | admin | admin123 |
| 游客 | linwan | user123 |

其余种子用户密码也是 `user123`。

## 本地运行

环境：JDK 17+、Maven 3.8+、Node.js 20+、MySQL 8。

```bash
mysql --default-character-set=utf8mb4 --init-command="SET time_zone='+08:00'" -u root -p < sql/schema.sql
mysql --default-character-set=utf8mb4 --init-command="SET time_zone='+08:00'" -u root -p < sql/data.sql
```

`sql/schema.sql` 末尾会创建数据库用户 `shanhe` / `shanhe123`，主机为 `localhost`、`127.0.0.1` 和 `%`，并授予 `shanhe` 库的全部权限。这与 `backend/src/main/resources/application.yml` 一致。只需用 root 导入这两个文件，不必再单独建用户。Docker Compose 里的后端仍使用 root，不受影响。

```bash
cd backend && mvn spring-boot:run
cd frontend && npm install && npm run dev
```

前台 <http://127.0.0.1:43123> ，接口 <http://127.0.0.1:8088> 。

也可以用 Docker Compose。项目名固定为 `shanhe`。MySQL 发布在宿主机 `13306`（容器内仍是 3306，避免占用本机 MySQL），后端 `8088`，前台 `43123`。这三个宿主机端口分别对应 `SHANHE_MYSQL_PORT`、`SHANHE_BACKEND_PORT`、`SHANHE_FRONTEND_PORT`。

```bash
docker compose up --build
```

浏览器打开 <http://127.0.0.1:43123> 。本机连接 Compose 里的 MySQL 用 `127.0.0.1:13306`，root 密码 `root123`。

双击一键脚本效果相同：macOS 用 `deploy-macos.command`，Windows 用 `deploy-windows.bat`。卸载用 `remove-macos.command` 或 `remove-windows.bat`。默认保留数据库卷，加上 `--purge-data` 才删除数据。

不用 Docker、直接在本机跑：macOS 用 `deploy-local-macos.command`（缺的 JDK、Maven、Node.js、MySQL 由 Homebrew 安装），Windows 用 `deploy-local-windows.bat`（由 winget 安装）。本机脚本连的是已经在跑的 MySQL，默认 `127.0.0.1:3306`，不会覆盖已有的 `shanhe` 库。停用 `remove-local-macos.command` 或 `remove-local-windows.bat`，同样要 `--purge-data` 才删库，并且不会卸载 JDK、Node.js、MySQL 或 Homebrew。两种方式的对照见 [docs/部署文档.md](docs/部署文档.md)。

更完整的步骤和时区说明见 [docs/部署文档.md](docs/部署文档.md)。设计说明见 [docs/网站设计报告.md](docs/网站设计报告.md)，同目录的 [docs/网站设计报告.pdf](docs/网站设计报告.pdf) 是按 A4、页边距 2.54 cm、小四、1.5 倍行距导出的正文，页数以这份 PDF 为准。上交压缩包的目录名和排除项见 [docs/打包说明.md](docs/打包说明.md)。

## 图片与视频

景点图、缩略图和首页横幅在 `frontend/public/media/images/`，都是 WebP。14 个景点的介绍视频在 `frontend/public/media/videos/<slug>.mp4`，数据库里的 `video_url` 写成 `/media/videos/<slug>.mp4`，由前台静态目录直接提供。其余景点仍使用 Wikimedia 的文件地址。作者、协议和原始页面见 [docs/ATTRIBUTION.md](docs/ATTRIBUTION.md)。这些 MP4 来自 B 站公开视频的 20 秒节选，未取得公开传播授权，仅供课程展示。

已经初始化过的数据库不会自动重跑 `sql/data.sql`。要给旧库补上这 14 条地址，执行 `sql/update_video_url.sql`。

重新生成演示数据：

```bash
python3 scripts/build_seed.py
```
