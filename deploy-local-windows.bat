@echo off
setlocal EnableExtensions DisableDelayedExpansion
rem Double-click to deploy without Docker. Use --no-pause when running from another script.
set "RESULT=1"
set "NO_PAUSE=0"
set "SHOW_HELP=0"
pushd "%~dp0" || exit /b 1
if not defined SHANHE_BACKEND_PORT set "SHANHE_BACKEND_PORT=8088"
if not defined SHANHE_FRONTEND_PORT set "SHANHE_FRONTEND_PORT=43123"
if not defined SHANHE_DB_HOST set "SHANHE_DB_HOST=127.0.0.1"
if not defined SHANHE_DB_PORT set "SHANHE_DB_PORT=3306"
if not defined SHANHE_WAIT_SECONDS set "SHANHE_WAIT_SECONDS=180"

:parse_args
if "%~1"=="" goto parsed
if /i "%~1"=="--no-pause" (
    set "NO_PAUSE=1"
    shift
    goto parse_args
)
if /i "%~1"=="--help" (
    set "SHOW_HELP=1"
    shift
    goto parse_args
)
echo [ERROR] Unknown argument. Use --help.
goto finish

:parsed
if "%SHOW_HELP%"=="1" goto help
echo === Shanhe local deployment / Windows ===
if not exist "sql\schema.sql" (
    echo [ERROR] Keep this script in the project root.
    goto finish
)
if not exist "backend\pom.xml" (
    echo [ERROR] Keep this script in the project root.
    goto finish
)
where curl >nul 2>&1
if errorlevel 1 (
    echo [ERROR] curl is required to check the application.
    goto finish
)
powershell.exe -NoProfile -Command "$ErrorActionPreference='Stop'; try { foreach ($n in @('SHANHE_BACKEND_PORT','SHANHE_FRONTEND_PORT','SHANHE_DB_PORT')) { $v=[Environment]::GetEnvironmentVariable($n); if ($v -notmatch '^\d+$' -or [int]$v -lt 1 -or [int]$v -gt 65535) { throw ('Invalid port: '+$n) } }; $s=$env:SHANHE_WAIT_SECONDS; if ($s -notmatch '^\d+$' -or [int]$s -lt 1) { throw 'Invalid SHANHE_WAIT_SECONDS' }; if ($env:SHANHE_DB_HOST -notmatch '^[A-Za-z0-9._-]+$') { throw 'Invalid SHANHE_DB_HOST' } } catch { Write-Host $_; exit 1 }"
if errorlevel 1 goto finish
if not exist ".shanhe-local" mkdir ".shanhe-local"

call :ensure_java
if errorlevel 1 goto finish
call :ensure_maven
if errorlevel 1 goto finish
call :ensure_node
if errorlevel 1 goto finish
call :ensure_mysql_listening
if errorlevel 1 goto finish
call :ensure_mysql_client
if errorlevel 1 goto finish
call :connect_mysql
if errorlevel 1 goto finish
call :check_mysql_version
if errorlevel 1 goto finish
call :load_database
if errorlevel 1 goto finish
call :choose_app_user

echo Building the backend...
pushd backend
call mvn -DskipTests package
set "BUILD_RC=%ERRORLEVEL%"
popd
if not "%BUILD_RC%"=="0" (
    echo [ERROR] Backend build failed. MySQL data was not deleted.
    goto finish
)
echo Building the frontend...
pushd frontend
call npm ci
if errorlevel 1 (
    popd
    echo [ERROR] Frontend build failed. MySQL data was not deleted.
    goto finish
)
call npm run build
if errorlevel 1 (
    popd
    echo [ERROR] Frontend build failed. MySQL data was not deleted.
    goto finish
)
popd

call :stop_pid ".shanhe-local\backend.pid" "shanhe-portal.jar"
call :stop_pid ".shanhe-local\frontend.pid" "local-frontend.mjs"
call :port_open %SHANHE_BACKEND_PORT%
if not errorlevel 1 (
    echo [ERROR] Port %SHANHE_BACKEND_PORT% is already in use. Set SHANHE_BACKEND_PORT or stop the other program.
    goto finish
)
call :port_open %SHANHE_FRONTEND_PORT%
if not errorlevel 1 (
    echo [ERROR] Port %SHANHE_FRONTEND_PORT% is already in use. Set SHANHE_FRONTEND_PORT or stop the other program.
    goto finish
)

echo Starting the backend and frontend...
powershell.exe -NoProfile -Command "$env:SERVER_PORT=$env:SHANHE_BACKEND_PORT; $env:SPRING_DATASOURCE_URL=('jdbc:mysql://' + $env:SHANHE_DB_HOST + ':' + $env:SHANHE_DB_PORT + '/shanhe?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true'); $env:SPRING_DATASOURCE_USERNAME=$env:SHANHE_APP_DB_USER; $env:SPRING_DATASOURCE_PASSWORD=$env:SHANHE_APP_DB_PASSWORD; $p = Start-Process -FilePath 'java' -ArgumentList @('-jar','backend\target\shanhe-portal.jar') -WorkingDirectory (Get-Location).Path -RedirectStandardOutput '.shanhe-local\backend.log' -RedirectStandardError '.shanhe-local\backend.err.log' -WindowStyle Hidden -PassThru; Set-Content -Path '.shanhe-local\backend.pid' -Value $p.Id"
if errorlevel 1 goto failed
powershell.exe -NoProfile -Command "$env:SHANHE_DIST = Join-Path (Get-Location).Path 'frontend\dist'; $env:SHANHE_BACKEND_HOST='127.0.0.1'; $p = Start-Process -FilePath 'node' -ArgumentList @('scripts\local-frontend.mjs') -WorkingDirectory (Get-Location).Path -RedirectStandardOutput '.shanhe-local\frontend.log' -RedirectStandardError '.shanhe-local\frontend.err.log' -WindowStyle Hidden -PassThru; Set-Content -Path '.shanhe-local\frontend.pid' -Value $p.Id"
if errorlevel 1 goto failed

echo Checking the frontend, backend and database...
powershell.exe -NoProfile -Command "$deadline=(Get-Date).AddSeconds([int]$env:SHANHE_WAIT_SECONDS); $url='http://127.0.0.1:'+$env:SHANHE_FRONTEND_PORT+'/api/home'; do { try { $r=Invoke-RestMethod -Uri $url -TimeoutSec 5 -ErrorAction Stop; if ($null -ne $r.code -and $r.code -eq 0 -and $null -ne $r.data) { exit 0 } } catch {}; Start-Sleep -Seconds 2 } while ((Get-Date) -lt $deadline); Write-Host '[ERROR] Homepage API did not become ready.'; exit 1"
if errorlevel 1 goto failed

echo.
echo [OK] Local deployment completed.
echo Website: http://127.0.0.1:%SHANHE_FRONTEND_PORT%
echo Admin:   http://127.0.0.1:%SHANHE_FRONTEND_PORT%/admin
echo Admin login: admin / admin123
echo User login:  linwan / user123
echo Stop: remove-local-windows.bat
echo Logs: .shanhe-local\backend.log and .shanhe-local\frontend.log
if exist ".shanhe-local\installed-by-script.txt" (
    echo Installed by this script and kept on disk:
    type ".shanhe-local\installed-by-script.txt"
) else (
    echo No packages were installed. Existing JDK, Maven, Node.js and MySQL were reused.
)
echo remove-local does not uninstall JDK, Maven, Node.js, MySQL or winget.
echo Database shanhe is kept unless remove-local-windows.bat is run with --purge-data.
echo SHANHE_MYSQL_PORT is the Docker host port and is not used by this script.
set "RESULT=0"
goto finish

:failed
echo.
echo [ERROR] The site did not become ready. MySQL data was not deleted.
echo Logs: .shanhe-local\backend.log and .shanhe-local\frontend.log
if exist ".shanhe-local\backend.log" powershell.exe -NoProfile -Command "Get-Content -Path '.shanhe-local\backend.log' -Tail 40"
if exist ".shanhe-local\backend.err.log" powershell.exe -NoProfile -Command "Get-Content -Path '.shanhe-local\backend.err.log' -Tail 40"
if exist ".shanhe-local\frontend.log" powershell.exe -NoProfile -Command "Get-Content -Path '.shanhe-local\frontend.log' -Tail 20"
goto finish

:help
echo Usage: deploy-local-windows.bat [--no-pause] [--help]
echo Build and start Shanhe on this machine. Docker is not used.
echo Missing JDK 17, Maven, Node.js or MySQL 8 are installed with winget.
echo An already running MySQL is reused and is not reinstalled.
echo Credentials: SHANHE_DB_HOST, SHANHE_DB_PORT, SHANHE_DB_USER, SHANHE_DB_PASSWORD.
echo Ports: SHANHE_BACKEND_PORT ^(default 8088^), SHANHE_FRONTEND_PORT ^(default 43123^), SHANHE_DB_PORT ^(default 3306^).
echo SHANHE_MYSQL_PORT is the Docker host port and is not used by this script.
set "RESULT=0"
goto finish

:ensure_java
where java >nul 2>&1
if errorlevel 1 goto install_java
powershell.exe -NoProfile -Command "$t = (& java -version 2>&1 | Select-Object -First 1 | Out-String).Trim(); if ($t -match 'version .1\.(\d+)') { $m=[int]$Matches[1] } elseif ($t -match 'version .(\d+)') { $m=[int]$Matches[1] } else { exit 1 }; if ($m -lt 17) { Write-Host ('Java ' + $m + ' is older than 17.'); exit 2 }; Write-Host ('Java ' + $m + ' is already installed.')"
if errorlevel 2 (
    echo [ERROR] Java is older than 17. Put JDK 17 or newer on PATH. This script will not replace it.
    exit /b 1
)
if errorlevel 1 goto install_java
exit /b 0
:install_java
call :require_winget
if errorlevel 1 exit /b 1
echo Installing OpenJDK 17...
call :winget_install EclipseAdoptium.Temurin.17.JDK
if errorlevel 1 (
    echo [ERROR] Could not install JDK 17.
    exit /b 1
)
where java >nul 2>&1
if errorlevel 1 (
    echo [ERROR] JDK 17 was installed, but java is still not on PATH. Open a new terminal and run this script again.
    exit /b 1
)
exit /b 0

:ensure_maven
where mvn >nul 2>&1
if errorlevel 1 goto install_maven
powershell.exe -NoProfile -Command "$t = (& mvn -version 2>&1 | Select-Object -First 1 | Out-String).Trim(); if ($t -notmatch '(\d+)\.(\d+)') { exit 1 }; if ([int]$Matches[1] -lt 3 -or ([int]$Matches[1] -eq 3 -and [int]$Matches[2] -lt 8)) { Write-Host ('Maven ' + $Matches[0] + ' is older than 3.8.'); exit 2 }; Write-Host ('Maven ' + $Matches[0] + ' is already installed.')"
if errorlevel 2 (
    echo [ERROR] Maven is older than 3.8. This script will not replace it.
    exit /b 1
)
if errorlevel 1 goto install_maven
exit /b 0
:install_maven
call :require_winget
if errorlevel 1 exit /b 1
echo Installing Maven...
call :winget_install Apache.Maven
if errorlevel 1 (
    echo [ERROR] Could not install Maven.
    exit /b 1
)
where mvn >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Maven was installed, but mvn is still not on PATH. Open a new terminal and run this script again.
    exit /b 1
)
exit /b 0

:ensure_node
where node >nul 2>&1
if errorlevel 1 goto install_node
powershell.exe -NoProfile -Command "$t = (& node -v).Trim().TrimStart('v'); $m=[int]($t.Split('.')[0]); if ($m -lt 20) { Write-Host ('Node.js ' + $t + ' is older than 20.'); exit 2 }; Write-Host ('Node.js ' + $t + ' is already installed.')"
if errorlevel 2 (
    echo [ERROR] Node.js is older than 20. This script will not replace it.
    exit /b 1
)
if errorlevel 1 goto install_node
exit /b 0
:install_node
call :require_winget
if errorlevel 1 exit /b 1
echo Installing Node.js...
call :winget_install OpenJS.NodeJS.LTS
if errorlevel 1 (
    echo [ERROR] Could not install Node.js.
    exit /b 1
)
where node >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js was installed, but node is still not on PATH. Open a new terminal and run this script again.
    exit /b 1
)
exit /b 0

:ensure_mysql_listening
if /i not "%SHANHE_DB_HOST%"=="127.0.0.1" if /i not "%SHANHE_DB_HOST%"=="localhost" (
    echo Using MySQL at %SHANHE_DB_HOST%:%SHANHE_DB_PORT%. No local server will be installed or started.
    exit /b 0
)
call :port_open %SHANHE_DB_PORT%
if not errorlevel 1 (
    echo MySQL is already listening on %SHANHE_DB_HOST%:%SHANHE_DB_PORT%. It will be reused and not reinstalled.
    exit /b 0
)
echo MySQL is not listening on port %SHANHE_DB_PORT%.
net start MySQL80 >nul 2>&1
net start MySQL84 >nul 2>&1
net start MySQL >nul 2>&1
call :port_open %SHANHE_DB_PORT%
if not errorlevel 1 exit /b 0
sc query MySQL80 >nul 2>&1
if not errorlevel 1 (
    echo [ERROR] The MySQL80 service exists but is not listening. Start it manually. No second server was installed and no data was changed.
    exit /b 1
)
where mysqld >nul 2>&1
if not errorlevel 1 (
    echo [ERROR] MySQL is installed but did not start. Start it manually. No second server was installed and no data was changed.
    exit /b 1
)
call :require_winget
if errorlevel 1 exit /b 1
echo Installing MySQL 8. The installer may ask for a root password.
echo Use that same value for SHANHE_DB_PASSWORD. An empty installer password matches an unset SHANHE_DB_PASSWORD.
call :winget_install Oracle.MySQL
if errorlevel 1 (
    echo [ERROR] Could not install MySQL. Install MySQL 8 from https://dev.mysql.com/downloads/mysql/ and run this script again.
    exit /b 1
)
call :add_mysql_path
net start MySQL80 >nul 2>&1
net start MySQL84 >nul 2>&1
call :port_open %SHANHE_DB_PORT%
if errorlevel 1 (
    echo [ERROR] MySQL was installed but is not listening on port %SHANHE_DB_PORT%. Start the service, then run this script again.
    exit /b 1
)
exit /b 0

:ensure_mysql_client
call :add_mysql_path
where mysql >nul 2>&1
if errorlevel 1 (
    echo [ERROR] The mysql client is not on PATH. Install MySQL 8 client tools and run this script again.
    exit /b 1
)
exit /b 0

:add_mysql_path
if exist "%ProgramFiles%\MySQL\MySQL Server 8.0\bin\mysql.exe" set "PATH=%ProgramFiles%\MySQL\MySQL Server 8.0\bin;%PATH%"
if exist "%ProgramFiles%\MySQL\MySQL Server 8.4\bin\mysql.exe" set "PATH=%ProgramFiles%\MySQL\MySQL Server 8.4\bin;%PATH%"
exit /b 0

:connect_mysql
if defined SHANHE_DB_USER goto db_given
set "SHANHE_DB_USER=root"
set "SHANHE_DB_PASSWORD="
call :mysql_ping
if not errorlevel 1 goto db_connected
set "SHANHE_DB_USER=shanhe"
set "SHANHE_DB_PASSWORD=shanhe123"
call :mysql_ping
if not errorlevel 1 goto db_connected
echo [ERROR] MySQL is running at %SHANHE_DB_HOST%:%SHANHE_DB_PORT%, but login failed. Set SHANHE_DB_USER and SHANHE_DB_PASSWORD. Existing data was not modified.
exit /b 1
:db_given
if not defined SHANHE_DB_PASSWORD set "SHANHE_DB_PASSWORD="
call :mysql_ping
if errorlevel 1 (
    echo [ERROR] Cannot connect to MySQL as %SHANHE_DB_USER%. Check SHANHE_DB_PASSWORD. Existing data was not modified.
    exit /b 1
)
:db_connected
echo Connected to MySQL as %SHANHE_DB_USER%.
exit /b 0

:mysql_ping
set "MYSQL_PWD=%SHANHE_DB_PASSWORD%"
mysql --protocol=TCP --connect-timeout=8 --batch --skip-column-names -h %SHANHE_DB_HOST% -P %SHANHE_DB_PORT% -u %SHANHE_DB_USER% --password=%SHANHE_DB_PASSWORD% -e "SELECT 1" >nul 2>&1
set "PING_RC=%ERRORLEVEL%"
set "MYSQL_PWD="
exit /b %PING_RC%

:check_mysql_version
set "MYSQL_VERSION="
for /f "delims=" %%V in ('mysql --protocol=TCP --connect-timeout=8 --batch --skip-column-names -h %SHANHE_DB_HOST% -P %SHANHE_DB_PORT% -u %SHANHE_DB_USER% --password=%SHANHE_DB_PASSWORD% -e "SELECT VERSION()"') do set "MYSQL_VERSION=%%V"
echo %MYSQL_VERSION% | find /i "MariaDB" >nul
if not errorlevel 1 (
    echo [ERROR] The server is MariaDB ^(%MYSQL_VERSION%^). MySQL 8 is required. It was not modified.
    exit /b 1
)
for /f "tokens=1 delims=." %%M in ("%MYSQL_VERSION%") do set "MYSQL_MAJOR=%%M"
if "%MYSQL_MAJOR%"=="" (
    echo [ERROR] Could not read the MySQL version.
    exit /b 1
)
if %MYSQL_MAJOR% LSS 8 (
    echo [ERROR] MySQL 8 or newer is required. This server reports %MYSQL_VERSION%. It was not upgraded or replaced.
    exit /b 1
)
exit /b 0

:load_database
set "DB_EXISTS="
mysql --protocol=TCP --connect-timeout=8 --batch --skip-column-names -h %SHANHE_DB_HOST% -P %SHANHE_DB_PORT% -u %SHANHE_DB_USER% --password=%SHANHE_DB_PASSWORD% -e "SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='shanhe'" > ".shanhe-local\db-check.txt"
set /p DB_EXISTS=<".shanhe-local\db-check.txt"
if "%DB_EXISTS%"=="shanhe" (
    echo Database shanhe already exists. Tables and data were left unchanged.
    exit /b 0
)
echo Database shanhe does not exist. Loading sql\schema.sql and sql\data.sql...
mysql --protocol=TCP --connect-timeout=8 --default-character-set=utf8mb4 --init-command="SET time_zone='+08:00'" -h %SHANHE_DB_HOST% -P %SHANHE_DB_PORT% -u %SHANHE_DB_USER% --password=%SHANHE_DB_PASSWORD% < sql\schema.sql
if errorlevel 1 goto db_load_failed
mysql --protocol=TCP --connect-timeout=8 --default-character-set=utf8mb4 --init-command="SET time_zone='+08:00'" -h %SHANHE_DB_HOST% -P %SHANHE_DB_PORT% -u %SHANHE_DB_USER% --password=%SHANHE_DB_PASSWORD% < sql\data.sql
if errorlevel 1 goto db_load_failed
mysql --protocol=TCP --connect-timeout=8 --batch --skip-column-names -h %SHANHE_DB_HOST% -P %SHANHE_DB_PORT% -u %SHANHE_DB_USER% --password=%SHANHE_DB_PASSWORD% -D shanhe -e "SELECT COUNT(*) FROM scenic_spot" > ".shanhe-local\spot-count.txt"
set /p SPOT_COUNT=<".shanhe-local\spot-count.txt"
if "%SPOT_COUNT%"=="" goto db_load_failed
if "%SPOT_COUNT%"=="0" goto db_load_failed
echo Loaded demo data: %SPOT_COUNT% scenic spots.
exit /b 0
:db_load_failed
echo Load failed. Dropping the incomplete shanhe database so the next run can retry.
mysql --protocol=TCP --connect-timeout=8 --batch -h %SHANHE_DB_HOST% -P %SHANHE_DB_PORT% -u %SHANHE_DB_USER% --password=%SHANHE_DB_PASSWORD% -e "DROP DATABASE IF EXISTS shanhe"
echo [ERROR] Could not load sql\schema.sql and sql\data.sql. Use an account that can CREATE DATABASE, often root.
exit /b 1

:choose_app_user
set "SHANHE_APP_DB_USER=shanhe"
set "SHANHE_APP_DB_PASSWORD=shanhe123"
set "MYSQL_PWD=shanhe123"
mysql --protocol=TCP --connect-timeout=8 --batch -h %SHANHE_DB_HOST% -P %SHANHE_DB_PORT% -u shanhe --password=shanhe123 -e "SELECT 1" >nul 2>&1
if errorlevel 1 (
    set "SHANHE_APP_DB_USER=%SHANHE_DB_USER%"
    set "SHANHE_APP_DB_PASSWORD=%SHANHE_DB_PASSWORD%"
    echo The shanhe database user is not available. The backend will use %SHANHE_DB_USER%.
)
set "MYSQL_PWD="
exit /b 0

:winget_install
winget install --id %~1 -e --accept-package-agreements --accept-source-agreements --disable-interactivity
if errorlevel 1 exit /b 1
>>".shanhe-local\installed-by-script.txt" echo %~1
call :refresh_path
exit /b 0

:require_winget
where winget >nul 2>&1
if errorlevel 1 (
    echo [ERROR] winget is required to install missing tools. Install App Installer, or install the missing tool yourself and run this script again.
    exit /b 1
)
exit /b 0

:refresh_path
for /f "delims=" %%P in ('powershell.exe -NoProfile -Command "[Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')"') do set "PATH=%%P"
exit /b 0

:port_open
powershell.exe -NoProfile -Command "try { $c = New-Object Net.Sockets.TcpClient; $c.Connect('127.0.0.1', %~1); $c.Close(); exit 0 } catch { exit 1 }"
exit /b

:stop_pid
if not exist "%~1" exit /b 0
set /p STOP_PID=<"%~1"
powershell.exe -NoProfile -Command "$p = Get-CimInstance Win32_Process -Filter ('ProcessId=' + '%STOP_PID%') -ErrorAction SilentlyContinue; if ($p -and $p.CommandLine -like '*%~2*') { Stop-Process -Id %STOP_PID% -Force -ErrorAction SilentlyContinue }"
exit /b 0

:finish
popd
if "%NO_PAUSE%"=="0" pause
exit /b %RESULT%
