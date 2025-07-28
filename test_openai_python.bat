@echo off
echo =======================================
echo OpenAI API Key Test Script (Python)
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

REM Install requests if needed
echo Installing required packages...
pip install requests

echo.
echo Running OpenAI API test (Python)...
echo.

python test_openai_simple.py

echo.
pause 