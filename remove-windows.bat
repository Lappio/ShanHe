@echo off
setlocal EnableExtensions DisableDelayedExpansion
rem Remove only the Shanhe Docker deployment. Data deletion requires --purge-data.
set "RESULT=1"
set "NO_PAUSE=0"
set "SHOW_HELP=0"
set "VOLUME_OPTION="
pushd "%~dp0" || exit /b 1

:parse_args
if "%~1"=="" goto parsed
if /i "%~1"=="--no-pause" (
    set "NO_PAUSE=1"
    shift
    goto parse_args
)
if /i "%~1"=="--purge-data" (
    set "VOLUME_OPTION=--volumes"
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
echo === Shanhe removal / Windows ===
if not exist "docker-compose.yml" (
    echo [ERROR] Keep this script in the project root with docker-compose.yml.
    goto finish
)
where docker >nul 2>&1
if errorlevel 1 if exist "%ProgramFiles%\Docker\Docker\resources\bin\docker.exe" set "PATH=%ProgramFiles%\Docker\Docker\resources\bin;%PATH%"
where docker >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker was not found. No resources were removed.
    goto finish
)
call docker compose version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker Compose v2 or newer is required.
    goto finish
)
call docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running. Start your Docker runtime manually ^(Docker Desktop or the WSL engine^) and run this script again.
    goto finish
)
if defined VOLUME_OPTION (
    echo Removing project containers, network, built images AND database data...
) else (
    echo Removing project containers, network and built images; keeping database data...
)
call docker compose -p shanhe -f docker-compose.yml down --rmi local %VOLUME_OPTION%
if errorlevel 1 (
    echo [ERROR] Removal did not complete. Review the Docker errors above and retry.
    goto finish
)
echo [OK] Removal completed.
if defined VOLUME_OPTION (
    echo Database data was deleted. The next deployment will load fresh demo data.
) else (
    echo Database data was kept. Use --purge-data to delete it as well.
)
echo Docker Desktop, shared base images and host software have been kept.
set "RESULT=0"
goto finish

:help
echo Usage: remove-windows.bat [--purge-data] [--no-pause] [--help]
echo Default: remove Shanhe containers, network and locally built service images.
echo --purge-data: also permanently delete the Shanhe database volume.
echo Docker Desktop, shared base images and host software are kept.
set "RESULT=0"

:finish
popd
if "%NO_PAUSE%"=="0" pause
exit /b %RESULT%
