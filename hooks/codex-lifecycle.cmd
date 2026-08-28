@echo off
call "%~dp0..\templates\hooks\run-hook.cmd" "..\..\hooks\codex-lifecycle"
exit /b %ERRORLEVEL%
