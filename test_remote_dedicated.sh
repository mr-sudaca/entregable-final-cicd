#!/bin/bash

# Script to run dedicated remote browser tests
# Usage: ./test_remote_dedicated.sh https://your-app.herokuapp.com

if [ -z "$1" ]; then
    echo "❌ Error: Please provide the remote URL"
    echo "Usage: $0 <remote_url>"
    echo "Example: $0 https://your-app.herokuapp.com"
    exit 1
fi

REMOTE_URL="$1"

echo "🌐 Running dedicated remote browser tests against: $REMOTE_URL"
echo "📝 Note: These tests are specifically designed for remote testing"
echo ""

# Export the remote URL and run the dedicated remote tests
export REMOTE_URL="$REMOTE_URL"
bundle exec rspec spec/acceptance/remote_browser_spec.rb --format documentation

echo ""
echo "✅ Dedicated remote browser testing completed!"
