# OpenAI API Key Test Script (PowerShell)
# Tests your OpenAI API key using native PowerShell commands

Write-Host "=" * 50 -ForegroundColor Cyan
Write-Host "OpenAI API Key Test Script (PowerShell)" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Cyan
Write-Host ""

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

Write-Host "🔍 Testing OpenAI API Key..." -ForegroundColor Yellow

# Check if API key is set
if (-not $OPENAI_API_KEY) {
    Write-Host "❌ OPENAI_API_KEY not found" -ForegroundColor Red
    Write-Host "Please set your OpenAI API key:" -ForegroundColor Yellow
    Write-Host "1. Create a .env file from env.example" -ForegroundColor Yellow
    Write-Host "2. Or set environment variable: `$env:OPENAI_API_KEY='your_api_key_here'" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if API key looks valid
if (-not $OPENAI_API_KEY.StartsWith("sk-")) {
    Write-Host "❌ API key format appears invalid (should start with 'sk-')" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✅ API key found: $($OPENAI_API_KEY.Substring(0,10))..." -ForegroundColor Green

# Test API connection
Write-Host "🔄 Testing API connection..." -ForegroundColor Yellow

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
                "content" = "Hello, this is a test message."
            }
        )
        "max_tokens" = 10
        "temperature" = 0
    } | ConvertTo-Json -Depth 3
    
    $response = Invoke-RestMethod -Uri "https://api.openai.com/v1/chat/completions" -Method Post -Headers $headers -Body $body -TimeoutSec 30
    
    if ($response.choices -and $response.choices.Count -gt 0) {
        Write-Host "✅ API connection successful!" -ForegroundColor Green
        Write-Host "✅ Response received: $($response.choices[0].message.content)" -ForegroundColor Green
    } else {
        Write-Host "❌ No response received from API" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "❌ API connection failed: $($_.Exception.Message)" -ForegroundColor Red
    
    # Show more details if available
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode
        Write-Host "Status Code: $statusCode" -ForegroundColor Red
        
        if ($statusCode -eq 401) {
            Write-Host "This usually means your API key is invalid or expired" -ForegroundColor Yellow
        } elseif ($statusCode -eq 429) {
            Write-Host "This means you've hit rate limits or are out of credits" -ForegroundColor Yellow
        }
    }
    
    Read-Host "Press Enter to exit"
    exit 1
}

# Test model list (optional)
Write-Host "🔄 Testing model list access..." -ForegroundColor Yellow

try {
    $modelsResponse = Invoke-RestMethod -Uri "https://api.openai.com/v1/models" -Method Get -Headers $headers -TimeoutSec 10
    
    if ($modelsResponse.data) {
        $modelCount = $modelsResponse.data.Count
        Write-Host "✅ Available models: $modelCount models found" -ForegroundColor Green
        
        # Show some common models
        $commonModels = @("gpt-4", "gpt-4o", "gpt-4o-mini", "gpt-3.5-turbo")
        $foundModels = $modelsResponse.data | Where-Object { $_.id -match "gpt-4|gpt-3.5" } | Select-Object -First 3
        
        if ($foundModels) {
            $modelNames = ($foundModels | ForEach-Object { $_.id }) -join ", "
            Write-Host "✅ Common models available: $modelNames" -ForegroundColor Green
        }
    }
    
} catch {
    Write-Host "⚠️  Model list access failed: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "This is not critical - your API key is working!" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 OpenAI API test completed successfully!" -ForegroundColor Green
Write-Host "✅ All tests passed! Your OpenAI API key is working correctly." -ForegroundColor Green

Read-Host "Press Enter to exit" 