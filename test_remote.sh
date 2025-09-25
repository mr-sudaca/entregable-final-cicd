#!/bin/bash

# Script to run browser tests against a remote deployed application
# Usage: ./test_remote.sh https://your-app.herokuapp.com

if [ -z "$1" ]; then
    echo "❌ Error: Please provide the remote URL"
    echo "Usage: $0 <remote_url>"
    echo "Example: $0 https://your-app.herokuapp.com"
    exit 1
fi

REMOTE_URL="$1"

echo "🌐 Running browser tests against remote URL: $REMOTE_URL"
echo "📝 Note: Some tests will be skipped as they require local mocking"
echo ""

# Export the remote URL and run the tests
export REMOTE_URL="$REMOTE_URL"
bundle exec rspec spec/acceptance/browser_spec.rb --format documentation

echo ""
echo "✅ Remote browser testing completed!"
echo "💡 Tip: Tests that require mocking (loading states, API errors) are skipped for remote testing"
