@echo off
title Jekyll Local Server Runner
cls

echo =====================================================================
echo  Jekyll 로컬 개발 서버를 구동합니다.
echo =====================================================================
echo.
echo  [^#] 접속 주소: http://localhost:4000/
echo  [^#] 종료하려면 터미널 창에서 Ctrl + C를 누르세요.
echo.
echo =====================================================================
echo.

start http://localhost:4000/

:: Jekyll 로컬 서버 구동 명령어 실행
bundle exec jekyll serve

pause