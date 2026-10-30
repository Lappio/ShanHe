@echo off
setlocal EnableExtensions DisableDelayedExpansion
rem Stop the native Shanhe processes. Data deletion requires --purge-data.
set "RESULT=1"
set "NO_PAUSE=0"
set "SHOW_HELP=0"
pushd "%~dp0" || exit /b 1
if not defined SHANHE_DB_HOST set "SHANHE_DB_HOST=127.0.0.1"
if not defined SHANHE_DB_PORT set "SHANHE_DB_PORT=3306"

:parse_args
if "%~1"=="" goto parsed
if /i "%~1"=="--no-pause" (
    set "NO_PAUSE=1"
    shift
    goto parse_args
)
if /i "%~1"=="--purge-data" (
    set "PURGE_DATA=1"
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
echo === Shanhe local removal / Windows ===
if not exist "sql\schema.sql" (
    echo [ERROR] Keep this script in the project root.
    goto finish
)
call :stop_pid ".shanhe-local\backend.pid" "shanhe-portal.jar"
call :stop_pid ".shanhe-local\frontend.pid" "local-frontend.mjs"

if not defined PURGE_DATA (
    echo Database shanhe was kept. Use --purge-data to drop it.
    goto cleanup
)
call :add_mysql_path
where mysql >nul 2>&1
if errorlevel 1 (
    echo [ERROR] The mysql client is not on PATH. Processes were stopped, but the shanhe database was not dropped.
    goto cleanup_failed
)
if defined SHANHE_DB_USER goto purge_given
set "SHANHE_DB_USER=root"
set "SHANHE_DB_PASSWORD="
call :mysql_ping
if not errorlevel 1 goto purge_drop
set "SHANHE_DB_USER=shanhe"
set "SHANHE_DB_PASSWORD=shanhe123"
call :mysql_ping
if not errorlevel 1 goto purge_drop
echo [ERROR] Set SHANHE_DB_USER and SHANHE_DB_PASSWORD to drop the database. Processes were stopped, but the database was kept.
goto cleanup_failed
:purge_given
if not defined SHANHE_DB_PASSWORD set "SHANHE_DB_PASSWORD="
call :mysql_ping
if errorlevel 1 (
    echo [ERROR] Cannot connect as %SHANHE_DB_USER%. The shanhe database was not dropped.
    goto cleanup_failed
)
:purge_drop
if not exist ".shanhe-local" mkdir ".shanhe-local"
set "DB_EXISTS="
mysql --protocol=TCP --connect-timeout=8 --batch --skip-column-names -h %SHANHE_DB_HOST% -P %SHANHE_DB_PORT% -u %SHANHE_DB_USER% --password=%SHANHE_DB_PASSWORD% -e "SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='shanhe'" > ".shanhe-local\db-check.txt"
set /p DB_EXISTS=<".shanhe-local\db-check.txt"
if "%DB_EXISTS%"=="shanhe" (
    mysql --protocol=TCP --connect-timeout=8 --batch -h %SHANHE_DB_HOST% -P %SHANHE_DB_PORT% -u %SHANHE_DB_USER% --password=%SHANHE_DB_PASSWORD% -e "DROP DATABASE shanhe"
    if errorlevel 1 (
        echo [ERROR] DROP DATABASE shanhe failed. The MySQL server was not uninstalled.
        goto cleanup_failed
    )
    echo Database shanhe was deleted. The MySQL account and server were kept.
) else (
    echo Database shanhe was not present.
)

:cleanup
if exist ".shanhe-local\installed-by-script.txt" (
    echo These packages were installed by deploy-local and were kept:
    type ".shanhe-local\installed-by-script.txt"
) else (
    echo No record of packages installed by deploy-local.
)
echo JDK, Maven, Node.js, MySQL and winget were not uninstalled.
echo Removing backend\target, frontend\dist and .shanhe-local...
if exist "backend\target" rmdir /s /q "backend\target"
if exist "frontend\dist" rmdir /s /q "frontend\dist"
if exist ".shanhe-local" rmdir /s /q ".shanhe-local"
echo [OK] Local removal completed.
echo node_modules was kept so the next build can reuse it.
set "RESULT=0"
goto finish

:cleanup_failed
if exist ".shanhe-local\installed-by-script.txt" (
    echo These packages were installed by deploy-local and were kept:
    type ".shanhe-local\installed-by-script.txt"
)
echo JDK, Maven, Node.js, MySQL and winget were not uninstalled.
if exist "backend\target" rmdir /s /q "backend\target"
if exist "frontend\dist" rmdir /s /q "frontend\dist"
if exist ".shanhe-local" rmdir /s /q ".shanhe-local"
goto finish

:help
echo Usage: remove-local-windows.bat [--purge-data] [--no-pause] [--help]
echo Default: stop the native backend and frontend, and delete build output.
echo Build output is backend\target, frontend\dist and .shanhe-local\.
echo --purge-data: also drop the shanhe database. The MySQL server itself is kept.
echo JDK, Maven, Node.js, MySQL and winget are never uninstalled.
set "RESULT=0"
goto finish

:add_mysql_path
if exist "%ProgramFiles%\MySQL\MySQL Server 8.0\bin\mysql.exe" set "PATH=%ProgramFiles%\MySQL\MySQL Server 8.0\bin;%PATH%"
if exist "%ProgramFiles%\MySQL\MySQL Server 8.4\bin\mysql.exe" set "PATH=%ProgramFiles%\MySQL\MySQL Server 8.4\bin;%PATH%"
exit /b 0

:mysql_ping
set "MYSQL_PWD=%SHANHE_DB_PASSWORD%"
mysql --protocol=TCP --connect-timeout=8 --batch --skip-column-names -h %SHANHE_DB_HOST% -P %SHANHE_DB_PORT% -u %SHANHE_DB_USER% --password=%SHANHE_DB_PASSWORD% -e "SELECT 1" >nul 2>&1
set "PING_RC=%ERRORLEVEL%"
set "MYSQL_PWD="
exit /b %PING_RC%

:stop_pid
if not exist "%~1" exit /b 0
set /p STOP_PID=<"%~1"
powershell.exe -NoProfile -Command "$p = Get-CimInstance Win32_Process -Filter ('ProcessId=' + '%STOP_PID%') -ErrorAction SilentlyContinue; if ($p -and $p.CommandLine -like '*%~2*') { Stop-Process -Id %STOP_PID% -Force -ErrorAction SilentlyContinue }"
exit /b 0

:finish
popd
if "%NO_PAUSE%"=="0" pause
exit /b %RESULT%
