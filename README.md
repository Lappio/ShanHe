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

每一条按现象、原因、处理来写。

### Docker 起不来，或提示需要 Compose v2

**现象：** `deploy-macos.command` / `deploy-windows.bat` 报 Docker 不可用，或 `Docker Compose v2 or newer is required`。

**原因：** 本机没有正在运行的 Docker，或只有旧的 `docker-compose`（带连字符）而没有 `docker compose`。脚本用 `docker compose version` 判断。Docker 没启动时，macOS 会尝试打开 Docker Desktop 并最多等 120 秒，然后提示改用已在运行的 OrbStack 或 Colima；Windows 同样等 120 秒，并接受已经运行的 WSL 引擎。

**处理：** 安装并打开 [Docker Desktop](https://www.docker.com/products/docker-desktop/)，或先自行启动 Engine，确认 `docker info` 和 `docker compose version` 都能成功，再执行部署脚本。

### 端口 13306、8088 或 43123 被占用

**现象：** 部署失败，日志里是端口绑定错误。脚本会提示设置 `SHANHE_MYSQL_PORT`、`SHANHE_BACKEND_PORT` 或 `SHANHE_FRONTEND_PORT`。失败时已有数据卷会保留。

**原因：** Compose 默认把 MySQL 映射到宿主机 `13306`、后端 `8088`、前台 `43123`。本机脚本的 MySQL 默认是 `3306`（`SHANHE_DB_PORT`），网站端口与 Compose 相同。

**处理：** Docker 部署改这三个 `SHANHE_*` 变量后重跑脚本。打开的网站地址跟着 `SHANHE_FRONTEND_PORT` 走。容器内部仍是 MySQL `3306`、后端 `8088`，JDBC 仍是 `jdbc:mysql://mysql:3306/shanhe`。本机脚本改 `SHANHE_DB_PORT`、`SHANHE_BACKEND_PORT`、`SHANHE_FRONTEND_PORT`，它不读 `SHANHE_MYSQL_PORT`。手动部署时同时改 `application.yml` 的 `server.port` 和 `frontend/vite.config.js` 的 `server.port` 与 `/api` 的 `target`。

### 等到超时，页面一直没就绪

**现象：** 脚本在构建或健康检查后退出，并打印 `docker compose ps` 与最近 60 行日志。

**原因：** `SHANHE_WAIT_SECONDS` 默认 `180`。Docker 脚本把它传给 `docker compose up --wait --wait-timeout`，随后再花同样长的时间请求 `http://127.0.0.1:${SHANHE_FRONTEND_PORT}/api/home`，直到 JSON 里 `code` 为 0 且 `data` 为对象。本机脚本只用它等待同一个地址。值必须是大于等于 1 的整数，否则脚本直接报 `Invalid SHANHE_WAIT_SECONDS`。首次构建要拉镜像，180 秒可能不够。

**处理：** 加大等待，例如 `SHANHE_WAIT_SECONDS=300 bash deploy-macos.command`（Windows 先 `set SHANHE_WAIT_SECONDS=300`）。同时看日志里是构建失败、数据库未健康，还是端口冲突。

### 后端连不上数据库

**现象：** 后端日志出现连接拒绝，或账号密码错误。前台 `/api/home` 没有数据。

**原因：** 手动部署读 `application.yml`：`127.0.0.1:3306`，用户 `shanhe`，密码 `shanhe123`。Compose 用环境变量覆盖为 `jdbc:mysql://mysql:3306/shanhe`、用户 `root`、密码 `root123`。本机脚本用 `SHANHE_DB_HOST`、`SHANHE_DB_PORT` 和实际连上的账号写入 `SPRING_DATASOURCE_URL`、`SPRING_DATASOURCE_USERNAME`、`SPRING_DATASOURCE_PASSWORD`。MySQL 没启动，或这三处不一致，都会拒绝连接。

**处理：** 先用同一组主机、端口、账号登录 `mysql`。手动部署保证已经导入 `sql/schema.sql`（其中会创建 `shanhe` 用户）。改端口或密码时，文件和 `SPRING_DATASOURCE_*` 一起改。

### MySQL 8 的认证、字符集和时区

**现象：** 驱动报 `Public Key Retrieval is not allowed`；页面中文变成问号；统计图最右边一天是空的。

**原因：** MySQL 8 默认认证插件是 `caching_sha2_password`。本仓库的 JDBC 地址已经带 `useSSL=false&allowPublicKeyRetrieval=true`（`application.yml`，以及 Compose、本机脚本拼出的 `SPRING_DATASOURCE_URL`）。导入时若没用 `utf8mb4`，中文会坏。订单和「今天」按 `Asia/Shanghai` 计算；导入会话不是 `+08:00` 时，`CURDATE()` 和 JVM 会差一天。Compose 的 MySQL 还设置了 `--default-time-zone=+08:00` 和 `utf8mb4`。

**处理：** 保留 JDBC 地址里的 `useSSL=false` 和 `allowPublicKeyRetrieval=true`。导入使用第 1 节那两条带 `--default-character-set=utf8mb4` 和 `SET time_zone='+08:00'` 的命令。字符集或时区已经错了的库，用这两条命令重新导入；`schema.sql` 会清掉业务表。

### 改了 SQL，Docker 里的数据却没变

**现象：** 修改 `sql/schema.sql` 或 `sql/data.sql` 后重新 `up`，库里仍是旧数据。

**原因：** 这两个文件挂在 `/docker-entrypoint-initdb.d/`，只在数据卷第一次创建时执行。

**处理：** 确认要清空后再删卷。macOS：`bash remove-macos.command --purge-data`。Windows：`remove-windows.bat --purge-data`。等价命令是 `docker compose -p shanhe -f docker-compose.yml down --rmi local --volumes`，然后重新部署。不加 `--purge-data` 只删容器和本项目镜像，卷还在。本机库要用 `remove-local-macos.command --purge-data` 或 `remove-local-windows.bat --purge-data`，那是 `DROP DATABASE shanhe`，不是删 Docker 卷。

### macOS 双击脚本被系统拦住，或没有执行权限

**现象：** 双击 `.command` 时系统提示无法打开，或终端显示 `Permission denied`。

**原因：** 从浏览器或压缩包得到的脚本可能带隔离属性。双击还要求文件可执行。四个 `.command` 在仓库里都是可执行文件；执行位丢失后双击会失败。

**处理：** 在仓库根目录用 bash 运行，不依赖执行位，例如 `bash deploy-macos.command`。仍要双击时，先 `chmod +x deploy-macos.command remove-macos.command deploy-local-macos.command remove-local-macos.command`。若隔离属性拦住，对对应文件执行 `xattr -d com.apple.quarantine`，再双击。

### Windows 的 bat 无法识别，或提示没有 winget

**现象：** 双击 `.bat` 后命令被拆开、出现意外的 `'...' is not recognized`；或本机部署脚本写 `winget is required`。

**原因：** 仓库里的 `deploy-windows.bat`、`deploy-local-windows.bat`、`remove-windows.bat`、`remove-local-windows.bat` 是 CRLF、无 BOM 的 ASCII。被编辑器存成仅 LF 后，`cmd` 会把续行和标签解析错。`winget` 只出现在 `deploy-local-windows.bat`：缺少 JDK、Maven、Node.js 或 MySQL 时它才会调用。Docker 的 `deploy-windows.bat` 不用 winget。

**处理：** 把被改成 LF 的 bat 存回 CRLF 再运行。缺少 winget 时安装 App Installer，或自行装好对应软件并保证 `java`、`mvn`、`node`、`mysql` 在 PATH 上，然后重跑。

### 本机脚本登不上 MySQL，Windows 也不询问密码

**现象：** `Cannot connect` / `login failed`，并提示设置 `SHANHE_DB_USER` 和 `SHANHE_DB_PASSWORD`。Windows 上双击结束后直接失败，没有密码输入。

**原因：** 未设置 `SHANHE_DB_USER` 时，脚本先试 `root` 和空密码，再试 `shanhe` / `shanhe123`。macOS 仅在这两次都失败、标准输入是终端、且没有 `--no-pause` 时才询问。`deploy-local-windows.bat` 没有询问步骤。一旦设置了 `SHANHE_DB_USER`，就只使用这一对，密码缺省为空，不再试 `shanhe` / `shanhe123`。Windows 用 winget 安装的 MySQL 安装程序可能另设了 root 密码。默认主机是 `127.0.0.1`，端口是 `SHANHE_DB_PORT`（默认 `3306`）。

**处理：** 显式设置变量后再跑，例如 macOS：

```bash
SHANHE_DB_USER=root SHANHE_DB_PASSWORD='安装时设置的密码' bash deploy-local-macos.command
```

Windows 先 `set SHANHE_DB_USER=root` 和 `set SHANHE_DB_PASSWORD=...`。库已经在别的机器上时再加 `SHANHE_DB_HOST`。不要用 `SHANHE_MYSQL_PORT`，本机脚本不读它。

### 前台 `/api` 返回 404 或 502

**现象：** 页面能开，接口失败。开发者工具里 `/api/home` 等为 404 或 502。`scripts/local-frontend.mjs` 失败时正文是 `Bad gateway`。

**原因：** 浏览器请求的是前台同源的 `/api`（axios 的 `baseURL`）。三条代理不一样：

- `npm run dev`：Vite 把 `/api` 转到 `http://127.0.0.1:8088`。后端没启动时连接失败。
- `npm run preview`：`vite.config.js` 没有 `preview.proxy`，`/api` 找不到后端，得到 404。
- `node scripts/local-frontend.mjs`：转到 `SHANHE_BACKEND_HOST`:`SHANHE_BACKEND_PORT`（默认 `127.0.0.1:8088`）。连不上就是 502。
- Compose 的 `frontend/nginx.conf`：`/api/` 转到 `http://backend:8088`。`backend` 只在 Compose 网络里能解析。把这份配置原样放到宿主机 Nginx 上，也会 502。

**处理：** 先执行 `curl http://127.0.0.1:8088/api/health`，确认后端返回 `{"code":0,"message":"ok","data":"山河纪"}`。开发用 `npm run dev`。本机生产构建用仓库根目录的 `node scripts/local-frontend.mjs`。宿主机 Nginx 把上游写成 `http://127.0.0.1:8088`。Compose 里保持服务名 `backend`。

### 登录之后出现 401

**现象：** 打开订单、收藏、个人中心或后台时接口为 HTTP 401，JSON 里 `code` 为 401、`message` 为「请先登录」。页面会清掉本地登录并转到 `/login`。

**原因：** `JwtInterceptor` 读取 `Authorization: Bearer`。下列情况都当成未登录：没有令牌、签名不对、超过 `shanhe.jwt.expire-hours`（72 小时）、用户 `status` 不是 1，或令牌里的 `ver` 和 `user.token_version` 不一致。修改密码会把 `token_version` 加一，旧令牌立即失效。令牌存在 `localStorage` 的 `shanhe_token`。已登录但角色不是 `ADMIN` 时，`/api/admin` 返回 403「需要管理员权限」；路由守卫会把非管理员从 `/admin` 送回 `/`。

**处理：** 用第 1 节的种子账号重新登录。管理员是 `admin` / `admin123`，游客是 `linwan` / `user123`。改过密码后必须重新登录。

### 介绍视频打不开，或进度不是 `#t=` 的位置

**现象：** 详情页出现「当前浏览器无法播放此格式」，或视频长时间停在封面；能播时也不是从地址里的秒数开始。

**原因：** `<video>` 使用 `controls`、`playsinline`、`preload="metadata"`，把 `scenic_spot.video_url` 原样当作 `src`，没有 `autoplay`，也没有在脚本里设置 `currentTime`。外链失败时同样会触发 `error`，页面就显示上面那句，并不只表示编码不对。九寨沟、桂林漓江、厦门鼓浪屿、泰山、苏州拙政园、乐山大佛、重庆洪崖洞、三亚亚龙湾、张掖丹霞的地址在 Archive.org，其余若干条在 `upload.wikimedia.org`。起播秒数是 URL 里的 `#t=`（例如九寨沟 `#t=298`）。有的浏览器要等元数据加载后才应用这个片段，有的会忽略。当前种子地址都是 `https://`，站点默认是 `http://127.0.0.1:43123`，因此不是 HTTPS 页面去拉 HTTP 资源。页面打开后视频不会自己播放，要点控件。

**处理：** 在新标签直接打开该 `video_url`。若带 `#t=` 的地址打不开，先去掉 `#t=` 及后面的部分再试文件本身。文件也打不开时，换一个能访问 Archive.org 或 Wikimedia 的网络。片段被忽略时，用播放器进度条自行拖到该秒数。不要给 `<video>` 加上 `autoplay` 来“修”这个现象：当前页面本来就等用户点击。

### 峨眉山、曲阜三孔、平遥古城没有视频

**现象：** 这三处没有播放器，文案是「暂无介绍视频，可先浏览景点图集。」

**原因：** `sql/data.sql` 里这三条的 `video_url` 为 NULL。`spot.videoUrl` 为空时模板不渲染 `<video>`。

**处理：** 这是当前种子数据，不必排查播放器。

### 旧库仍在请求 `/media/videos/`

**现象：** 详情视频 404，地址形如 `/media/videos/jiuzhaigou.mp4`。

**原因：** 更早的种子把介绍视频放在 `frontend/public/media/videos/<slug>.mp4`，这些文件已经从仓库删除。已经初始化的 MySQL 不会因为仓库里的 `data.sql` 更新而改写旧行。`sql/update_video_url.sql` 的注释把这种情况称为上一版的本地文件地址，并按景点名改成现在的外链。

**处理：** 全新导入当前 `sql/data.sql` 的库不用再跑。已有库执行：

```bash
mysql --default-character-set=utf8mb4 -u root -p shanhe < sql/update_video_url.sql
```

Compose 里的库在宿主机 `127.0.0.1` 和 `SHANHE_MYSQL_PORT`（默认 13306），root 密码 `root123`。

### 图片打不开，但和视频外链无关

**现象：** 封面或图集裂图，同时视频外链时通时不通。

**原因：** 页面图片来自站内 `frontend/public/media/images/*.webp`，库里的路径是 `/media/images/...`。Wikimedia 只写在图片署名（`spot_image.credit`）里，浏览器不会为此去请求 Wikimedia。

**处理：** 在网站上直接打开该 `/media/images/...` 路径。开发服务器读 `frontend/public`；生产构建后文件在 `frontend/dist`。文件不在这两处时，补回 WebP 或修正数据库里的路径。这和 Archive.org 是否可达无关。

## 系统说明

山河纪是一个全国热门景点文旅门户。游客查看景点、路线、游记和资讯，登录后预约门票、收藏和管理自己的订单；管理员维护内容、审核游记并处理订单。种子账号见上文「打开并验证」：管理员 `admin` / `admin123`，游客 `linwan` / `user123`。

### 游客端

前台路由在 `frontend/src/router/index.js`，导航在 `frontend/src/layouts/UserLayout.vue`。

- 首页 `/`：轮播、主题分类、按热度排列的景点、推荐路线、资讯。
- 景点 `/spots`：关键词同时匹配名称和城市，并可按分类、省份、票价筛选，排序有热度、最新、价格升序和降序。
- 详情 `/spots/:id`：图集、介绍视频、开放时间、地址、高德地图链接、在售门票、评论、收藏，以及同分类的其他景点。
- 路线 `/routes`、`/routes/:id`：多日行程。
- 游记 `/notes`：列表和详情对已通过（`APPROVED`）的游记公开。发布、编辑需要登录，新游记和再次保存后的状态为 `PENDING`。可以点赞。
- 资讯 `/news`、`/news/:id`。
- 预约 `/book/:id` 和个人订单 `/orders` 需要登录。游客只能取消自己状态为 `PENDING` 的订单。个人中心 `/user` 可改资料和密码，并查看收藏（景点、路线、游记）和自己的游记。
- 注册 `/register` 创建的角色固定为 `USER`。

### 管理后台

`/admin` 要求已登录且 `role` 为 `ADMIN`。侧栏与路由对应：

| 路径 | 页面 |
| --- | --- |
| `/admin/dashboard` | 数据统计：用户、在售景点、有效订单、成交额、今日订单、游记数量，以及近 14 日订单、热门景点订单、近 14 日新增用户、景点分类四张图 |
| `/admin/spots` | 景点管理 |
| `/admin/categories` | 分类管理 |
| `/admin/tickets` | 票种管理 |
| `/admin/routes` | 路线管理 |
| `/admin/orders` | 订单管理。待出行订单可改为已完成或已取消 |
| `/admin/notes` | 游记审核：通过（`APPROVED`）或驳回（`REJECTED`） |
| `/admin/comments` | 评论管理 |
| `/admin/users` | 用户管理 |
| `/admin/banners` | 轮播管理 |
| `/admin/news` | 资讯管理 |

已有订单的景点不能物理删除，接口返回「该景点已有订单，请改为下架」。仍被路线引用时，要先从路线里移除。已有订单的票种不能删除，也不能改所属景点。

### 结构与接口

浏览器只访问前台同源的 `/api`。Vite 开发服务器、`scripts/local-frontend.mjs` 和 Compose 里的 Nginx 再把它转到 Spring Boot。后端上下文路径就是 `/api`，管理接口在 `/api/admin`。响应体为 `code`、`message`、`data`，`code` 为 0 表示成功。

后端包在 `com.shanhe.portal` 下：`controller`、`service`、`mapper`（MyBatis-Plus）、`entity`、`dto`、`security`、`config`。数据库是 MySQL 库 `shanhe`。业务表包括 `user`、`spot_category`、`scenic_spot`、`spot_image`、`ticket_type`、`route`、`route_spot`、`travel_note`、`note_like`、`comment`、`favorite`、`booking_order`、`news`、`banner`。

登录签发 JWT，放在 `Authorization: Bearer` 中，密钥和有效期来自 `application.yml` 的 `shanhe.jwt`（默认 72 小时）。前端把令牌记在 `localStorage` 的 `shanhe_token`。密码用 BCrypt。公开的 GET 可以不登录；`/api/orders`、`/api/favorites`、`/api/user`、`/api/auth/me`、`/api/notes/mine`、游记和评论的写操作，以及全部 `/api/admin` 必须登录。管理接口另外要求角色 `ADMIN`。

预约在一个事务里防止超卖：先对票种 `SELECT ... FOR UPDATE`，再对当日未取消订单的数量 `SUM(...) FOR UPDATE`，与 `ticket_type.daily_stock` 比较，超出则拒绝。取消只是把状态改成 `CANCELLED`，之后不再计入已售。游玩日期使用 `Asia/Shanghai`，且须在今天起 60 天内。首页聚合有 Caffeine 缓存（`maximumSize=300,expireAfterWrite=120s`），景点、票种、路线等内容保存后由 `HomeCache` 清掉名为 `home` 的缓存。保存票种时会按在售票的最低价重算景点 `price_from`，没有在售票时写成空。

更完整的设计说明见 [docs/网站设计报告.md](docs/网站设计报告.md)。
