#!/usr/bin/env python3
"""
Simple OpenAI API Key Test Script
Tests your OpenAI API key with a basic connection and model list.
"""

import os
import sys
from openai import OpenAI
from config import get_openai_api_key

def test_openai_api():
    """Test OpenAI API key and connection"""
    print("🔍 Testing OpenAI API Key...")
    
    # Get API key from environment variables or .env file
    api_key = get_openai_api_key()
    if not api_key:
        print("❌ OPENAI_API_KEY not found")
        print("Please set your OpenAI API key:")
        print("1. Create a .env file from env.example")
        print("2. Or set environment variable: set OPENAI_API_KEY=your_api_key_here")
        return False
    
    # Check if API key looks valid
    if not api_key.startswith('sk-'):
        print("❌ API key format appears invalid (should start with 'sk-')")
        return False
    
    print(f"✅ API key found: {api_key[:10]}...")
    
    try:
        # Initialize client
        client = OpenAI(api_key=api_key)
        print("✅ OpenAI client initialized")
        
        # Test connection with a simple request
        print("🔄 Testing API connection...")
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": "Hello, this is a test message."}],
            max_tokens=10,
            temperature=0
        )
        
        if response and response.choices:
            print("✅ API connection successful!")
            print(f"✅ Response received: {response.choices[0].message.content}")
        else:
            print("❌ No response received from API")
            return False
            
    except Exception as e:
        print(f"❌ API connection failed: {str(e)}")
        return False
    
    # Test model list (optional)
    try:
        print("🔄 Testing model list access...")
        models = client.models.list()
        available_models = [model.id for model in models.data]
        print(f"✅ Available models: {len(available_models)} models found")
        
        # Show some common models
        common_models = ['gpt-4', 'gpt-4o', 'gpt-4o-mini', 'gpt-3.5-turbo']
        found_models = [model for model in available_models if any(common in model for common in common_models)]
        if found_models:
            print(f"✅ Common models available: {found_models[:3]}")
        
    except Exception as e:
        print(f"⚠️  Model list access failed: {str(e)}")
        print("This is not critical - your API key is working!")
    
    print("\n🎉 OpenAI API test completed successfully!")
    return True

def main():
    """Main function"""
    print("=" * 50)
    print("OpenAI API Key Test Script")
    print("=" * 50)
    
    success = test_openai_api()
    
    if success:
        print("\n✅ All tests passed! Your OpenAI API key is working correctly.")
        sys.exit(0)
    else:
        print("\n❌ Tests failed. Please check your API key and try again.")
        sys.exit(1)

if __name__ == "__main__":
    main() 