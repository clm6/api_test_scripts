@echo off
echo ===============================================
echo OpenAI API Test Scripts Setup
echo ===============================================

REM Check if .env file exists
if exist .env (
    echo ✅ .env file already exists
    goto :install_deps
) else (
    echo 📋 Setting up .env file...
    if exist env.example (
        copy env.example .env
        echo ✅ Created .env file from template
        echo.
        echo ⚠️  IMPORTANT: Please edit .env file and add your OpenAI API key
        echo    Your API key should start with 'sk-'
        echo.
        pause
    ) else (
        echo ❌ env.example not found
        goto :error
    )
)

:install_deps
echo 📦 Installing Python dependencies...
pip install -r requirements.txt

if %errorlevel% neq 0 (
    echo ❌ Failed to install dependencies
    goto :error
)

echo.
echo ✅ Setup complete!
echo.
echo Next steps:
echo 1. Edit .env file and add your OpenAI API key
echo 2. Run test_openai_python.bat to test your setup
echo.
pause
goto :end

:error
echo.
echo ❌ Setup failed. Please check the errors above.
pause

:end 