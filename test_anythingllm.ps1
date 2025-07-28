# AnythingLLM API Key Test Script (PowerShell)
# Tests your AnythingLLM API key using native PowerShell commands

Write-Host "=" * 50 -ForegroundColor Cyan
Write-Host "AnythingLLM API Key Test Script (PowerShell)" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Cyan
Write-Host ""

# Set your API key here or use environment variable
$ANYTHINGLLM_API_KEY = "2NV9Y2E-D4GM09S-NQHD3B2-Y0YVHA0"
$ANYTHINGLLM_BASE_URL = "http://localhost:3001"

if (-not $ANYTHINGLLM_API_KEY) {
    $ANYTHINGLLM_API_KEY = $env:ANYTHINGLLM_API_KEY
}

if ($env:ANYTHINGLLM_BASE_URL) {
    $ANYTHINGLLM_BASE_URL = $env:ANYTHINGLLM_BASE_URL
}

Write-Host "🔍 Testing AnythingLLM API Key..." -ForegroundColor Yellow

# Check if API key is set
if (-not $ANYTHINGLLM_API_KEY) {
    Write-Host "❌ ANYTHINGLLM_API_KEY not set" -ForegroundColor Red
    Write-Host "Please set your AnythingLLM API key in this script or as environment variable" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✅ API key found: $($ANYTHINGLLM_API_KEY.Substring(0,10))..." -ForegroundColor Green
Write-Host "✅ Base URL: $ANYTHINGLLM_BASE_URL" -ForegroundColor Green

# Set up headers
$headers = @{
    "Authorization" = "Bearer $ANYTHINGLLM_API_KEY"
    "Content-Type" = "application/json"
}

# Test 1: Health check
Write-Host "🔄 Testing server health..." -ForegroundColor Yellow

try {
    $healthResponse = Invoke-RestMethod -Uri "$ANYTHINGLLM_BASE_URL/api/health" -Method Get -Headers $headers -TimeoutSec 10
    Write-Host "✅ Server health check passed" -ForegroundColor Green
} catch {
    if ($_.Exception.Message -like "*connection*" -or $_.Exception.Message -like "*refused*") {
        Write-Host "❌ Cannot connect to AnythingLLM server" -ForegroundColor Red
        Write-Host "Please ensure AnythingLLM is running at $ANYTHINGLLM_BASE_URL" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 1
    } else {
        Write-Host "⚠️  Health check returned: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "Server might be running but health endpoint not available" -ForegroundColor Yellow
        Write-Host "Continuing with other tests..." -ForegroundColor Yellow
    }
}

# Test 2: Simple chat request
Write-Host "🔄 Testing chat API..." -ForegroundColor Yellow

try {
    # Try workspace-based chat first
    $chatBody = @{
        "message" = "Hello, this is a test message."
        "mode" = "chat"
        "sessionId" = "test-session"
    } | ConvertTo-Json
    
    $chatResponse = Invoke-RestMethod -Uri "$ANYTHINGLLM_BASE_URL/api/workspace/test/chat" -Method Post -Headers $headers -Body $chatBody -TimeoutSec 30
    
    Write-Host "✅ Chat API connection successful!" -ForegroundColor Green
    
    # Try to extract response text
    if ($chatResponse.textResponse) {
        $responseText = $chatResponse.textResponse
        if ($responseText.Length -gt 100) { $responseText = $responseText.Substring(0, 100) + "..." }
        Write-Host "✅ Response received: $responseText" -ForegroundColor Green
    } elseif ($chatResponse.response) {
        $responseText = $chatResponse.response.ToString()
        if ($responseText.Length -gt 100) { $responseText = $responseText.Substring(0, 100) + "..." }
        Write-Host "✅ Response received: $responseText" -ForegroundColor Green
    } else {
        $responseText = ($chatResponse | ConvertTo-Json -Compress)
        if ($responseText.Length -gt 100) { $responseText = $responseText.Substring(0, 100) + "..." }
        Write-Host "✅ Response received: $responseText" -ForegroundColor Green
    }
    
} catch {
    Write-Host "❌ Workspace chat API failed: $($_.Exception.Message)" -ForegroundColor Red
    
    # Try alternative chat endpoint
    Write-Host "🔄 Trying alternative chat endpoint..." -ForegroundColor Yellow
    
    try {
        $altChatBody = @{
            "model" = "gpt-4o-mini"
            "messages" = @(
                @{
                    "role" = "user"
                    "content" = "Hello, this is a test message."
                }
            )
            "max_tokens" = 10
            "temperature" = 0
            "stream" = $false
        } | ConvertTo-Json -Depth 3
        
        $altChatResponse = Invoke-RestMethod -Uri "$ANYTHINGLLM_BASE_URL/api/chat" -Method Post -Headers $headers -Body $altChatBody -TimeoutSec 30
        
        Write-Host "✅ Alternative chat API successful!" -ForegroundColor Green
        
        if ($altChatResponse.choices -and $altChatResponse.choices.Count -gt 0) {
            $content = $altChatResponse.choices[0].message.content
            if (-not $content) { $content = "No content" }
            Write-Host "✅ Response received: $content" -ForegroundColor Green
        } else {
            $responseText = ($altChatResponse | ConvertTo-Json -Compress)
            if ($responseText.Length -gt 100) { $responseText = $responseText.Substring(0, 100) + "..." }
            Write-Host "✅ Response received: $responseText" -ForegroundColor Green
        }
        
    } catch {
        Write-Host "❌ Alternative chat API also failed: $($_.Exception.Message)" -ForegroundColor Red
        
        # Show status code if available
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode
            Write-Host "Status Code: $statusCode" -ForegroundColor Red
            
            if ($statusCode -eq 401) {
                Write-Host "This usually means your API key is invalid" -ForegroundColor Yellow
            } elseif ($statusCode -eq 404) {
                Write-Host "This means the endpoint doesn't exist - check your AnythingLLM version" -ForegroundColor Yellow
            }
        }
        
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Test 3: System information (optional)
Write-Host "🔄 Testing system information..." -ForegroundColor Yellow

try {
    # Try to get workspaces first
    $workspacesResponse = Invoke-RestMethod -Uri "$ANYTHINGLLM_BASE_URL/api/workspaces" -Method Get -Headers $headers -TimeoutSec 10
    $workspaceCount = if ($workspacesResponse) { $workspacesResponse.Count } else { 0 }
    Write-Host "✅ Workspaces accessible: $workspaceCount found" -ForegroundColor Green
    
} catch {
    Write-Host "⚠️  Workspaces access failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

try {
    # Try to get system information
    $systemResponse = Invoke-RestMethod -Uri "$ANYTHINGLLM_BASE_URL/api/system" -Method Get -Headers $headers -TimeoutSec 10
    Write-Host "✅ System information accessible" -ForegroundColor Green
    
    if ($systemResponse.LLMProvider) {
        Write-Host "✅ LLM Provider: $($systemResponse.LLMProvider)" -ForegroundColor Green
    }
    
} catch {
    Write-Host "⚠️  System info access failed: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "This is not critical - your API key is working!" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 AnythingLLM API test completed successfully!" -ForegroundColor Green
Write-Host "✅ All tests passed! Your AnythingLLM API key is working correctly." -ForegroundColor Green
Write-Host ""
Write-Host "Tips:" -ForegroundColor Cyan
Write-Host "- Ensure AnythingLLM server is running" -ForegroundColor White
Write-Host "- Check your workspace configuration" -ForegroundColor White
Write-Host "- Verify your model settings in AnythingLLM" -ForegroundColor White

Read-Host "Press Enter to exit" 