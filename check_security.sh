#!/bin/bash

# Pre-Push Security Check
# Run this before pushing to GitHub

echo "🔍 Checking for exposed credentials..."

# Define patterns to search for
PATTERNS=(
    "AC5c5e5daaa"
    "0bb5dbed"
    "918090298390"
    "14155238886"
    "13252412544"
)

FOUND=0

for pattern in "${PATTERNS[@]}"; do
    if git grep -n "$pattern" -- "*.dart" "*.json" "*.yaml" >/dev/null 2>&1; then
        echo "❌ DANGER: Found credential pattern '$pattern' in committed files!"
        git grep -n "$pattern" -- "*.dart" "*.json" "*.yaml"
        FOUND=1
    fi
done

if [ $FOUND -eq 0 ]; then
    echo "✅ No credentials found in tracked files"
    echo "✅ Safe to push to GitHub!"
    exit 0
else
    echo ""
    echo "🚨 STOP! DO NOT PUSH!"
    echo "Credentials detected in your code."
    echo "Remove them and use .env file instead."
    exit 1
fi
