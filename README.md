# 山河纪 · 全国热门景点文旅门户

游客前台与管理后台。前端 Vue 3 / Vite，后端 Spring Boot 3（Java 17），数据库 MySQL 8。开发时前台把 `/api` 转到本机 `8088`；Docker 里由 Nginx 反代。

| 部分 | 技术 | 默认地址 |
| --- | --- | --- |
| 前端 | Vue 3、Vite、Vue Router、Pinia、Element Plus | <http://127.0.0.1:43123> |
| 后端 | Spring Boot 3.3.6、MyBatis-Plus、JWT | <http://127.0.0.1:8088> |
| 数据库 | MySQL 8.0，库名 `shanhe` | 本机 `3306`；Compose 宿主机 `13306` |

更细的步骤、时区和端口说明见 [docs/部署文档.md](docs/部署文档.md)。

## 部署

### 1. 手动部署

不使用仓库里的 `deploy-*` / `remove-*` 脚本。

**环境**

| 软件 | 版本 |
| --- | --- |
| JDK | 17 或以上（`backend/pom.xml` 的 `java.version` 为 17） |
| Maven | 3.8 或以上。仓库没有 `mvnw`，使用已安装的 `mvn` |
| Node.js | 20 或以上，自带 npm |
| MySQL | 8.x。不要用 MariaDB |

**导入数据库**

`sql/schema.sql` 会 `CREATE DATABASE shanhe`，建表，并创建用户 `shanhe` / `shanhe123`（主机 `localhost`、`127.0.0.1`、`%`），授予 `shanhe.*`。用能够 `CREATE DATABASE` 和 `CREATE USER` 的账号导入，一般是 root。导入时指定 utf8mb4 和东八区：

```bash
mysql --default-character-set=utf8mb4 --init-command="SET time_zone='+08:00'" -u root -p < sql/schema.sql
mysql --default-character-set=utf8mb4 --init-command="SET time_zone='+08:00'" -u root -p < sql/data.sql
```

当前 `schema.sql` 已包含 `user.token_version` 和各表 CHECK。按这份仓库全新导入后，不必再执行 `sql/migrate_v4.sql`。

再次导入 `schema.sql` 会按外键顺序删掉全部业务表再重建。已有数据的库不要整文件重导，改跑 `python3 scripts/apply_migrate_v4.py`（见下文）。`data.sql` 只插入数据，重复导入会主键冲突。

**配置后端数据库连接**

文件：`backend/src/main/resources/application.yml`。

- `server.port`：`8088`
- `spring.datasource.url`：`jdbc:mysql://127.0.0.1:3306/shanhe?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true`
- `spring.datasource.username`：`shanhe`
- `spring.datasource.password`：`shanhe123`

可用环境变量覆盖，与 Docker 和本机脚本相同：`SPRING_DATASOURCE_URL`、`SPRING_DATASOURCE_USERNAME`、`SPRING_DATASOURCE_PASSWORD`。改监听端口时设置 `SERVER_PORT`，或直接改 `server.port`。

**构建并运行后端**

```bash
cd backend
mvn spring-boot:run
```

或打包后运行：

```bash
cd backend
mvn -DskipTests package
java -jar target/shanhe-portal.jar
```

**安装并运行前端**

开发服务器（`frontend/vite.config.js` 监听 `0.0.0.0:43123`，把 `/api` 代理到 `http://127.0.0.1:8088`，路径不改写）：

```bash
cd frontend
npm install
npm run dev
```

浏览器请求的是 `http://127.0.0.1:43123/api/...`（axios 的 `baseURL` 为 `/api`）。后端改端口后，同时改 `vite.config.js` 里的 `server.proxy['/api'].target`。

`vite.config.js` 只写了 `server.proxy`，没有 `preview.proxy`。`npm run preview` 不会转发 `/api`。

生产构建：

```bash
cd frontend
npm install
npm run build
```

产物在 `frontend/dist`。托管时需要两件事：`/api` 反代到后端，其余路径回退到 `index.html`。

- `frontend/nginx.conf`（Compose 前台镜像使用）：`/api/` 转到 `http://backend:8088`（Compose 服务名），`/` 使用 `try_files` 回退 `index.html`。在宿主机单独用 Nginx 时，把上游改成 `http://127.0.0.1:8088`。
- 在仓库根目录用自带的静态服务（规则与上面相同，上游默认 `127.0.0.1:8088`）：

```bash
node scripts/local-frontend.mjs
```

它读取 `SHANHE_DIST`（默认 `frontend/dist`，相对当前目录）、`SHANHE_FRONTEND_PORT`（默认 `43123`）、`SHANHE_BACKEND_HOST`（默认 `127.0.0.1`）、`SHANHE_BACKEND_PORT`（默认 `8088`）。

**打开并验证**

前台 <http://127.0.0.1:43123> ，后台 <http://127.0.0.1:43123/admin> 。接口直接访问：

```bash
curl http://127.0.0.1:8088/api/health
```

返回 `{"code":0,"message":"ok","data":"山河纪"}` 即后端正常。再打开前台首页，确认页面数据来自 `/api/home`。

`sql/data.sql` 写入的密码是 BCrypt。登录页和 `scripts/build_seed.py` 使用的明文如下，其余种子用户与 `linwan` 是同一条哈希：

| 角色 | 用户名 | 密码 |
| --- | --- | --- |
| 管理员 | admin | admin123 |
| 游客 | linwan | user123 |

### 2. Docker 一键运行（推荐）

需要 [Docker Desktop](https://www.docker.com/products/docker-desktop/)，或 Docker Engine 加上 Compose v2（`docker compose version` 可用）。macOS 上已经运行的 OrbStack、Colima，以及 Windows 上的 WSL 引擎，脚本也会直接使用。第一次构建需要能拉取镜像。

`docker-compose.yml` 里 `name: shanhe`。三个服务：`mysql`（镜像 `mysql:8.0`）、`backend`、`frontend`（Nginx，容器内 80）。MySQL 仅在数据卷第一次创建时执行 `sql/schema.sql` 和 `sql/data.sql`。

**端口环境变量**（未设置时用默认值）：

| 变量 | 默认 | 含义 |
| --- | --- | --- |
| `SHANHE_MYSQL_PORT` | `13306` | 宿主机端口，映射容器 `3306` |
| `SHANHE_BACKEND_PORT` | `8088` | 宿主机端口，映射容器 `8088` |
| `SHANHE_FRONTEND_PORT` | `43123` | 宿主机端口，映射容器 `80` |
| `SHANHE_WAIT_SECONDS` | `180` | `docker compose up --wait-timeout`，以及之后检查 `/api/home` 的最长等待秒数 |

容器内后端的 JDBC 固定为 `jdbc:mysql://mysql:3306/shanhe`，用户 `root`，密码 `root123`，不随宿主机的 `SHANHE_MYSQL_PORT` 变化。

**启动**

macOS（可双击，或在仓库根目录执行）：

```bash
bash deploy-macos.command
bash deploy-macos.command --no-pause
```

Windows：

```bat
deploy-windows.bat
deploy-windows.bat --no-pause
```

这两个部署脚本只把**第一个参数**识别为 `--no-pause`。有这个参数时，结束前不再等待按键。未加时，macOS 仅在标准输入是终端时等待，Windows 总会 `pause`。它们没有 `--help`，也不接受 `--purge-data`；把 `--purge-data` 传给部署脚本不会删数据。

脚本等价于：

```bash
docker compose -p shanhe -f docker-compose.yml up --build --detach --wait --wait-timeout "$SHANHE_WAIT_SECONDS"
```

随后请求 `http://127.0.0.1:${SHANHE_FRONTEND_PORT}/api/home`，直到 JSON 中 `code` 为 0 且 `data` 为对象。要占住当前终端并持续看日志，可以用：

```bash
docker compose up --build
```

`name: shanhe` 已写在 compose 文件中，所以上面这条不必再加 `-p`。停止与日志：

```bash
docker compose -p shanhe -f docker-compose.yml stop
docker compose -p shanhe -f docker-compose.yml logs -f
```

**停止并删除容器**

```bash
bash remove-macos.command
bash remove-macos.command --purge-data --no-pause
```

```bat
remove-windows.bat
remove-windows.bat --purge-data --no-pause
```

`--purge-data`、`--no-pause`、`--help` 可以组合，顺序不限。

默认执行：

```bash
docker compose -p shanhe -f docker-compose.yml down --rmi local
```

这会删除本项目的容器、网络和本地构建的镜像，保留数据卷。`--purge-data` 再加 `--volumes`，下次部署会重新导入种子数据。脚本不卸载 Docker Desktop，也不删除公共基础镜像。

**访问**

<http://127.0.0.1:43123> （若改过 `SHANHE_FRONTEND_PORT`，用该端口）。后台路径 `/admin`。从宿主机连数据库：`127.0.0.1:13306`，root 密码 `root123`；`schema.sql` 创建的 `shanhe` / `shanhe123` 也可以登录。

### 3. 本地部署脚本

这条路径会用 Homebrew（macOS）或 winget（Windows）在本机安装或启动 JDK、Maven、Node.js 和 MySQL，再编译并拉起进程。已有 MySQL、root 密码、PATH、权限或网络任一不满足，脚本就会停在中途。失败时改用上一节的 Docker，或按第 1 节手动部署。

| | macOS | Windows |
| --- | --- | --- |
| 启动 | `bash deploy-local-macos.command` | `deploy-local-windows.bat` |
| 停止 | `bash remove-local-macos.command` | `remove-local-windows.bat` |

部署脚本参数：`--no-pause`、`--help`（顺序不限）。停止脚本再加 `--purge-data`。部署脚本不接受 `--purge-data`。

**数据库环境变量**（本机脚本不读 `SHANHE_MYSQL_PORT`）：

| 变量 | 默认 | 说明 |
| --- | --- | --- |
| `SHANHE_DB_HOST` | `127.0.0.1` | 非本机地址时，不安装、不启动本地 MySQL |
| `SHANHE_DB_PORT` | `3306` | 已有进程在听该端口时直接复用，不重装 |
| `SHANHE_DB_USER` | 未设置 | 见下方尝试顺序 |
| `SHANHE_DB_PASSWORD` | 未设置时按空密码 | 只有同时设置了 `SHANHE_DB_USER` 才固定使用这一对 |

未设置 `SHANHE_DB_USER` 时，先试 `root` 空密码，再试 `shanhe` / `shanhe123`。macOS 在交互终端且没有 `--no-pause` 时，两次都失败会再询问账号。Windows 不询问，直接失败，需要自己设置这两个变量。一旦设置了 `SHANHE_DB_USER`，就只用这一对，密码缺省为空。

库 `shanhe` 不存在时才导入 `sql/schema.sql` 和 `sql/data.sql`（同样带 utf8mb4 和 `time_zone='+08:00'`）。库已存在则不改表。导入失败会 `DROP DATABASE shanhe`，便于下次重试。后端优先用 `shanhe` / `shanhe123`；该账号连不上时，改用刚才连上数据库的账号，并通过 `SPRING_DATASOURCE_*` 与 `SERVER_PORT` 传入。

另外两个端口与 Docker 相同：`SHANHE_BACKEND_PORT` 默认 `8088`，`SHANHE_FRONTEND_PORT` 默认 `43123`。`SHANHE_WAIT_SECONDS` 默认 `180`，用于等待 `http://127.0.0.1:${SHANHE_FRONTEND_PORT}/api/home`。

脚本在 `backend` 执行 `mvn -DskipTests package`，在 `frontend` 执行 `npm ci` 和 `npm run build`，然后启动 `backend/target/shanhe-portal.jar` 与 `node scripts/local-frontend.mjs`。JDK 低于 17、Maven 低于 3.8、Node.js 低于 20，或 MySQL 主版本低于 8（含 MariaDB）时会退出，不替换已安装的程序。缺 MySQL 时 macOS 用 `brew install mysql`，Windows 用 `winget install --id Oracle.MySQL`（安装程序可能要求设置 root 密码，把该密码赋给 `SHANHE_DB_PASSWORD`）。端口上没有进程时，脚本先尝试启动已有服务：macOS 在能找到 `mysqld`、`mysql.server` 或 Homebrew 的 mysql 时只启动、不重装；Windows 依次 `net start MySQL80`、`MySQL84`、`MySQL`，若 `MySQL80` 服务已存在或 PATH 上已有 `mysqld` 但仍未监听，则报错退出，不再装第二套。

**运行目录** `.shanhe-local/`：进程号（`backend.pid`、`frontend.pid`）和日志（`backend.log`、`frontend.log`；Windows 另有 `*.err.log`）。本次新装的包名记在 `installed-by-script.txt`。

**`--purge-data`** 只在停止脚本上：对 `SHANHE_DB_HOST`:`SHANHE_DB_PORT` 执行 `DROP DATABASE shanhe`。不加则保留该库。停止脚本还会删掉 `backend/target`、`frontend/dist` 和 `.shanhe-local/`，留下 `frontend/node_modules`。它不卸载 JDK、Maven、Node.js、MySQL，也不卸载 Homebrew 或 winget。

打开的地址与 Docker 相同：<http://127.0.0.1:43123> 。

## 项目结构

```
backend/                 Spring Boot，application.yml，端口 8088
frontend/                Vue 3 + Vite；nginx.conf 供镜像使用
sql/schema.sql           建库、建表、创建 shanhe 用户
sql/data.sql             种子数据
sql/migrate_v4.sql       仅给早于当前表结构的已有库
sql/update_video_url.sql 仅给仍保存旧视频地址的已有库
scripts/local-frontend.mjs
docker-compose.yml       项目名 shanhe
deploy-macos.command / deploy-windows.bat
deploy-local-macos.command / deploy-local-windows.bat
remove-*.command / remove-*.bat
docs/部署文档.md
```

## 图片与视频

景点图在 `frontend/public/media/images/`（WebP）。介绍视频不入库，`scenic_spot.video_url` 为外链：一部分是 Wikimedia，九寨沟、桂林漓江、厦门鼓浪屿、泰山、苏州拙政园、乐山大佛、重庆洪崖洞、三亚亚龙湾、张掖丹霞这 9 个是 Archive.org（`#t=` 为起播秒数）。部分网络访问 Archive.org 会较慢或打不开。峨眉山、曲阜三孔、平遥古城的 `video_url` 为 NULL，详情页提示先浏览图集。署名见 [docs/ATTRIBUTION.md](docs/ATTRIBUTION.md)。

新鲜导入的 `sql/data.sql` 已带这些地址。已有库不重导种子时，执行 `sql/update_video_url.sql`。重新生成种子：

```bash
python3 scripts/build_seed.py
```

## 对着数据库跑的脚本

`scripts/apply_migrate_v4.py` 和 `scripts/oversell_check.py` 默认连接 `127.0.0.1:3306`，用户 `shanhe`，密码 `shanhe123`（`SHANHE_DB_HOST`、`SHANHE_DB_PORT`、`SHANHE_DB_USER`、`SHANHE_DB_PASSWORD`）。这是本机 MySQL，不是 Compose 映射出来的端口。对着 Docker 里的库时，把端口设成 `SHANHE_MYSQL_PORT`（默认 13306）：

```bash
SHANHE_DB_PORT=13306 python3 scripts/apply_migrate_v4.py
SHANHE_DB_PORT=13306 python3 scripts/oversell_check.py
```

改过 `SHANHE_MYSQL_PORT` 时，这里用同一个值。`oversell_check.py` 的 HTTP 地址是 `SHANHE_API`，默认 `http://127.0.0.1:8088/api`。

## 常见问题

- 端口被占用：Docker 改 `SHANHE_MYSQL_PORT`、`SHANHE_BACKEND_PORT`、`SHANHE_FRONTEND_PORT`。本机脚本改 `SHANHE_DB_PORT`、`SHANHE_BACKEND_PORT`、`SHANHE_FRONTEND_PORT`（不读 `SHANHE_MYSQL_PORT`）。手动部署时同时改 `application.yml` 的 `server.port` 和 `frontend/vite.config.js` 的 `server.port` 与 `/api` 代理目标。容器内部的 3306 和 8088 不用改。
- 后端拒绝连接：MySQL 未启动，或账号与 `application.yml`（或 `SPRING_DATASOURCE_*`）不一致。
- 中文变问号：导入时漏了 `--default-character-set=utf8mb4`。
- 统计图最右一天是空的：导入会话时区不是 `+08:00`，与应用的 `Asia/Shanghai` 差了一天。按第 1 节的命令重新导入。
- Docker 里的数据没有更新：初始化 SQL 只在数据卷第一次创建时执行。要重来，先 `remove-macos.command --purge-data` 或 `remove-windows.bat --purge-data`，再部署。
- 前台接口 401：未登录或令牌过期。`shanhe.jwt.expire-hours` 为 72。

设计说明见 [docs/网站设计报告.md](docs/网站设计报告.md)。
