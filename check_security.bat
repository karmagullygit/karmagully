@echo off
REM Pre-Push Security Check for Windows
REM Run this before pushing to GitHub

echo Checking for exposed credentials...

set FOUND=0

git grep -n "AC5c5e5daaa" -- "*.dart" "*.json" "*.yaml" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo DANGER: Found Twilio Account SID in committed files!
    git grep -n "AC5c5e5daaa" -- "*.dart" "*.json" "*.yaml"
    set FOUND=1
)

git grep -n "0bb5dbed" -- "*.dart" "*.json" "*.yaml" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo DANGER: Found Twilio Auth Token in committed files!
    git grep -n "0bb5dbed" -- "*.dart" "*.json" "*.yaml"
    set FOUND=1
)

git grep -n "918090298390" -- "*.dart" "*.json" "*.yaml" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo DANGER: Found WhatsApp number in committed files!
    git grep -n "918090298390" -- "*.dart" "*.json" "*.yaml"
    set FOUND=1
)

if %FOUND% EQU 0 (
    echo ✅ No credentials found in tracked files
    echo ✅ Safe to push to GitHub!
    exit /b 0
) else (
    echo.
    echo 🚨 STOP! DO NOT PUSH!
    echo Credentials detected in your code.
    echo Remove them and use .env file instead.
    exit /b 1
)
