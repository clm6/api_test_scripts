# OpenAI API Test Scripts

Simple command line test scripts to verify your OpenAI API key.

## Files

### Python Scripts (Recommended)
- `test_openai_simple.py` - Test OpenAI API key and connection (Python)
- `test_openai_python.bat` - Windows batch file to run Python OpenAI test
- `test_openai.py` - Alternative Python test using OpenAI SDK

### PowerShell Scripts (No Python Required)
- `test_openai_simple.ps1` - Test OpenAI API key (PowerShell) ✅ **WORKING**
- `test_openai.ps1` - Alternative PowerShell test

### Setup & Configuration
- `env.example` - Template for API key configuration
- `config.py` - Python configuration module
- `setup.bat` - Automated setup script
- `requirements.txt` - Python dependencies

## Quick Setup

### Option 1: Automated Setup (Recommended)
1. Run `setup.bat` to automatically create `.env` file and install dependencies
2. Edit `.env` file and add your OpenAI API key
3. Run your preferred test script

### Option 2: Manual Setup
1. **Create .env file:**
   ```cmd
   copy env.example .env
   ```

2. **Edit .env file** and add your OpenAI API key:
   ```
   OPENAI_API_KEY=sk-your-actual-api-key-here
   ```

3. **Install Python Dependencies (for Python scripts):**
   ```cmd
   pip install -r requirements.txt
   ```

## Usage

### Option 1: PowerShell (No Python Required) - Recommended
- Right-click `test_openai_simple.ps1` → **"Run with PowerShell"**

### Option 2: Python (if Python is installed)
- Double-click `test_openai_python.bat` (installs dependencies automatically)
- Or run directly: `python test_openai_simple.py`

### Option 3: Batch Setup
- Double-click `setup.bat` for guided setup

## What the OpenAI Test Does

- ✅ Validates your API key format (should start with 'sk-')
- ✅ Tests connection with a simple chat completion request
- ✅ Shows the actual AI response to confirm it's working
- ✅ Lists available models (optional)
- ✅ Provides clear success/failure messages with troubleshooting

## Expected Output

✅ **Success**: Green checkmarks indicate passing tests  
⚠️ **Warning**: Yellow warnings for non-critical issues  
❌ **Error**: Red X marks indicate failures that need attention

## Troubleshooting

### Common OpenAI Issues
- ❌ **Invalid API key**: Ensure your API key starts with `sk-proj-` or `sk-`
- ❌ **No credits**: Check that you have sufficient OpenAI credits in your account
- ❌ **Network issues**: Verify internet connectivity
- ❌ **Rate limits**: Wait a moment and try again if you get 429 errors

## Security Features

🔒 **API Key Protection:**
- API keys are stored in `.env` file (not tracked by git)
- Scripts automatically load from environment variables
- No hardcoded credentials in source code
- Safe for public repositories

## API Key Setup

1. Get your API key from [OpenAI Platform](https://platform.openai.com/api-keys)
2. Copy `env.example` to `.env`
3. Replace `sk-your-openai-api-key-here` with your actual API key
4. Your API key should start with `sk-proj-` or `sk-` 