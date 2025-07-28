# Simple OpenAI API Test Script
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "OpenAI API Key Test" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Load API key from .env file or environment variable
$envFile = Join-Path $PSScriptRoot ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match "^([^#][^=]*?)=(.*)$") {
            [Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), "Process")
        }
    }
}

$OPENAI_API_KEY = $env:OPENAI_API_KEY

Write-Host "Testing OpenAI API Key..." -ForegroundColor Yellow

if (-not $OPENAI_API_KEY) {
    Write-Host "❌ OPENAI_API_KEY not found" -ForegroundColor Red
    Write-Host "Please set your OpenAI API key:" -ForegroundColor Yellow
    Write-Host "1. Create a .env file from env.example" -ForegroundColor Yellow
    Write-Host "2. Or set environment variable: `$env:OPENAI_API_KEY='your_api_key_here'" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Cyan
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

if (-not $OPENAI_API_KEY.StartsWith("sk-")) {
    Write-Host "❌ API key format appears invalid (should start with 'sk-')" -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Cyan
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host "API Key: $($OPENAI_API_KEY.Substring(0,15))..." -ForegroundColor Green

try {
    $headers = @{
        "Authorization" = "Bearer $OPENAI_API_KEY"
        "Content-Type" = "application/json"
    }
    
    $body = @{
        "model" = "gpt-3.5-turbo"
        "messages" = @(
            @{
                "role" = "user"
                "content" = "Say hello"
            }
        )
        "max_tokens" = 10
    } | ConvertTo-Json -Depth 3
    
    Write-Host "Making API request..." -ForegroundColor Yellow
    
    $response = Invoke-RestMethod -Uri "https://api.openai.com/v1/chat/completions" -Method Post -Headers $headers -Body $body -TimeoutSec 30
    
    if ($response.choices) {
        Write-Host "SUCCESS! OpenAI API is working!" -ForegroundColor Green
        Write-Host "Response: $($response.choices[0].message.content)" -ForegroundColor Green
    } else {
        Write-Host "FAILED: No response received" -ForegroundColor Red
    }
    
} catch {
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "Error 401: Invalid API key" -ForegroundColor Yellow
    } elseif ($_.Exception.Response.StatusCode -eq 429) {
        Write-Host "Error 429: Rate limit or out of credits" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Test completed. Press any key to exit..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 