#!/usr/bin/env python3
"""
Configuration module for API test scripts
Handles loading environment variables from .env file
"""

import os
from pathlib import Path

def load_env_file():
    """Load environment variables from .env file if it exists"""
    env_file = Path(__file__).parent / '.env'
    
    if env_file.exists():
        with open(env_file, 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    os.environ[key.strip()] = value.strip()

def get_openai_api_key():
    """Get OpenAI API key from environment variables"""
    load_env_file()
    return os.getenv('OPENAI_API_KEY')

def get_anythingllm_config():
    """Get AnythingLLM configuration from environment variables"""
    load_env_file()
    return {
        'api_key': os.getenv('ANYTHINGLLM_API_KEY'),
        'base_url': os.getenv('ANYTHINGLLM_BASE_URL', 'http://localhost:3001')
    } 