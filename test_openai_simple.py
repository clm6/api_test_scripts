#!/usr/bin/env python3
"""
Simple OpenAI API Key Test Script (Python)
Tests your OpenAI API key with a basic connection and response.
"""

import os
import sys
import requests
import json
from config import get_openai_api_key

def test_openai_api():
    """Test OpenAI API key and connection"""
    print("=" * 50)
    print("OpenAI API Key Test (Python)")
    print("=" * 50)
    
    # Get API key from environment variables or .env file
    OPENAI_API_KEY = get_openai_api_key()
    
    print("🔍 Testing OpenAI API Key...")
    
    # Check if API key is set
    if not OPENAI_API_KEY:
        print("❌ OPENAI_API_KEY not found")
        print("Please set your OpenAI API key:")
        print("1. Create a .env file from env.example")
        print("2. Or set environment variable: set OPENAI_API_KEY=your_api_key_here")
        input("Press Enter to exit...")
        return False
    
    # Check if API key looks valid
    if not OPENAI_API_KEY.startswith("sk-"):
        print("❌ API key format appears invalid (should start with 'sk-')")
        input("Press Enter to exit...")
        return False
    
    print(f"✅ API key found: {OPENAI_API_KEY[:15]}...")
    
    # Test API connection
    print("🔄 Testing API connection...")
    
    try:
        headers = {
            "Authorization": f"Bearer {OPENAI_API_KEY}",
            "Content-Type": "application/json"
        }
        
        data = {
            "model": "gpt-3.5-turbo",
            "messages": [
                {
                    "role": "user",
                    "content": "Say hello"
                }
            ],
            "max_tokens": 10,
            "temperature": 0
        }
        
        print("Making API request...")
        
        response = requests.post(
            "https://api.openai.com/v1/chat/completions",
            headers=headers,
            json=data,
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            if result.get('choices'):
                message = result['choices'][0]['message']['content']
                print("✅ SUCCESS! OpenAI API is working!")
                print(f"✅ Response: {message}")
            else:
                print("❌ FAILED: No response received")
                return False
        else:
            print(f"❌ API request failed with status: {response.status_code}")
            
            if response.status_code == 401:
                print("Error 401: Invalid API key")
            elif response.status_code == 429:
                print("Error 429: Rate limit or out of credits")
            else:
                print(f"Response: {response.text}")
            
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ API connection failed: {str(e)}")
        return False
    
    # Test model list (optional)
    print("🔄 Testing model list access...")
    
    try:
        models_response = requests.get(
            "https://api.openai.com/v1/models",
            headers=headers,
            timeout=10
        )
        
        if models_response.status_code == 200:
            models_data = models_response.json()
            if models_data.get('data'):
                model_count = len(models_data['data'])
                print(f"✅ Available models: {model_count} models found")
                
                # Show some common models
                common_models = ['gpt-4', 'gpt-4o', 'gpt-4o-mini', 'gpt-3.5-turbo']
                found_models = []
                
                for model in models_data['data']:
                    model_id = model.get('id', '')
                    for common in common_models:
                        if common in model_id:
                            found_models.append(model_id)
                            break
                
                if found_models:
                    print(f"✅ Common models available: {', '.join(found_models[:3])}")
        else:
            print(f"⚠️  Model list access failed: {models_response.status_code}")
            
    except requests.exceptions.RequestException as e:
        print(f"⚠️  Model list access failed: {str(e)}")
        print("This is not critical - your API key is working!")
    
    print("\n🎉 OpenAI API test completed successfully!")
    return True

def main():
    """Main function"""
    success = test_openai_api()
    
    if success:
        print("\n✅ All tests passed! Your OpenAI API key is working correctly.")
    else:
        print("\n❌ Tests failed. Please check your API key and try again.")
    
    input("\nPress Enter to exit...")

if __name__ == "__main__":
    main() 