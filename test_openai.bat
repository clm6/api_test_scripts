@echo off
echo =======================================
echo OpenAI API Key Test Script
echo =======================================
echo.

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed or not in PATH
    echo Please install Python and try again
    pause
    exit /b 1
)

REM Install requirements if needed
echo Installing required packages...
pip install -q openai requests

echo.
echo Running OpenAI API test...
echo.

python test_openai.py

echo.
pause 