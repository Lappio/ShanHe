@echo off
setlocal EnableExtensions DisableDelayedExpansion
rem Double-click to deploy. Use --no-pause when running from another script.
set "RESULT=1"
pushd "%~dp0" || exit /b 1
if not defined SHANHE_MYSQL_PORT set "SHANHE_MYSQL_PORT=13306"
if not defined SHANHE_BACKEND_PORT set "SHANHE_BACKEND_PORT=8088"
if not defined SHANHE_FRONTEND_PORT set "SHANHE_FRONTEND_PORT=43123"
if not defined SHANHE_WAIT_SECONDS set "SHANHE_WAIT_SECONDS=180"

echo === Shanhe deployment / Windows ===
if not exist "docker-compose.yml" (
    echo [ERROR] Keep this script in the project root with docker-compose.yml.
    goto finish
)
where docker >nul 2>&1
if errorlevel 1 if exist "%ProgramFiles%\Docker\Docker\resources\bin\docker.exe" set "PATH=%ProgramFiles%\Docker\Docker\resources\bin;%PATH%"
where docker >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Install and open Docker Desktop, then run this script again.
    echo https://www.docker.com/products/docker-desktop/
    goto finish
)
call docker compose version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker Compose v2 or newer is required. Update Docker Desktop.
    goto finish
)
powershell.exe -NoProfile -Command "$ErrorActionPreference='Stop'; try { foreach ($n in @('SHANHE_MYSQL_PORT','SHANHE_BACKEND_PORT','SHANHE_FRONTEND_PORT')) { $v=[Environment]::GetEnvironmentVariable($n); if ($v -notmatch '^\d+$' -or [int]$v -lt 1 -or [int]$v -gt 65535) { throw ('Invalid port: '+$n) } }; $s=$env:SHANHE_WAIT_SECONDS; if ($s -notmatch '^\d+$' -or [int]$s -lt 1) { throw 'Invalid SHANHE_WAIT_SECONDS' } } catch { Write-Host $_; exit 1 }"
if errorlevel 1 goto finish

call docker info >nul 2>&1
if not errorlevel 1 goto docker_ready
if not exist "%ProgramFiles%\Docker\Docker\Docker Desktop.exe" (
    echo [ERROR] Docker is not running, and Docker Desktop was not found. Start your Docker runtime manually ^(the WSL engine also works^) and run this script again.
    goto finish
)
echo Starting Docker Desktop; waiting up to 120 seconds...
powershell.exe -NoProfile -Command "Start-Process -FilePath ($env:ProgramFiles+'\Docker\Docker\Docker Desktop.exe') -WindowStyle Hidden"
for /l %%i in (1,1,60) do (
    call docker info >nul 2>&1
    if not errorlevel 1 goto docker_ready
    powershell.exe -NoProfile -Command "Start-Sleep -Seconds 2"
)
echo [ERROR] Docker is unavailable. Start Docker Desktop ^(Linux containers^) or your WSL Docker engine, then run this script again.
goto finish

:docker_ready
call docker compose -p shanhe -f docker-compose.yml config --quiet
if errorlevel 1 goto finish
echo Building images and starting services. The first run needs Internet access.
call docker compose -p shanhe -f docker-compose.yml up --build --detach --wait --wait-timeout %SHANHE_WAIT_SECONDS%
if errorlevel 1 goto failed
echo Checking the frontend, backend and database...
powershell.exe -NoProfile -Command "$deadline=(Get-Date).AddSeconds([int]$env:SHANHE_WAIT_SECONDS); $url='http://127.0.0.1:'+$env:SHANHE_FRONTEND_PORT+'/api/home'; do { try { $r=Invoke-RestMethod -Uri $url -TimeoutSec 5 -ErrorAction Stop; if ($null -ne $r.code -and $r.code -eq 0 -and $null -ne $r.data) { exit 0 } } catch {}; Start-Sleep -Seconds 2 } while ((Get-Date) -lt $deadline); Write-Host '[ERROR] Homepage API did not become ready.'; exit 1"
if errorlevel 1 goto failed

echo.
echo [OK] Deployment completed.
echo Website: http://127.0.0.1:%SHANHE_FRONTEND_PORT%
echo Admin:   http://127.0.0.1:%SHANHE_FRONTEND_PORT%/admin
echo Admin login: admin / admin123
echo User login:  linwan / user123
echo Stop: docker compose -p shanhe -f docker-compose.yml stop
echo Logs: docker compose -p shanhe -f docker-compose.yml logs -f
set "RESULT=0"
goto finish

:failed
echo.
echo [ERROR] Deployment failed. Existing database volumes have been kept.
echo If a port is occupied, set SHANHE_MYSQL_PORT, SHANHE_BACKEND_PORT or SHANHE_FRONTEND_PORT and retry.
call docker compose -p shanhe -f docker-compose.yml ps
call docker compose -p shanhe -f docker-compose.yml logs --tail 60

:finish
popd
if /i not "%~1"=="--no-pause" pause
exit /b %RESULT%
