#!/bin/bash

# CI Setup Script
# Configura el ambiente para ejecutar tests en CI

set -e

echo "🔧 Setting up CI environment..."

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Check Node.js version
NODE_VERSION=$(node -v)
echo -e "${BLUE}Node.js version: $NODE_VERSION${NC}"

# Check npm version
NPM_VERSION=$(npm -v)
echo -e "${BLUE}npm version: $NPM_VERSION${NC}"

# Install dependencies
echo -e "${BLUE}Installing dependencies...${NC}"
npm ci

# Set environment variables for CI
export CI=true
export NODE_ENV=test

echo -e "${GREEN}✅ CI environment setup complete${NC}"