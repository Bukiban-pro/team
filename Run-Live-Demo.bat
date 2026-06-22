@echo off
cd /d "%~dp0collabspace"
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "docs\defense\run-live-demo.ps1"
pause
