#!/bin/bash

# Smoke test script for quick deployment validation
# Usage: ./smoke_test.sh [remote_url]

echo "💨 Starting Horoscope App Smoke Tests"
echo "======================================"

if [ -n "$1" ]; then
    REMOTE_URL="$1"
    export REMOTE_URL
    echo "🌐 Target: Remote URL ($REMOTE_URL)"
else
    echo "🏠 Target: Local application"
fi

echo ""
echo "🚀 Running minimal smoke tests..."
echo ""

# Run smoke tests with minimal output
bundle exec rspec spec/smoke/smoke_test_spec.rb \
    --format progress \
    --no-profile \
    --fail-fast

exit_code=$?

echo ""
if [ $exit_code -eq 0 ]; then
    echo "✅ Smoke tests PASSED - Application is healthy!"
    echo "🎉 Deployment validation successful"
else
    echo "❌ Smoke tests FAILED - Application has issues!"
    echo "🚨 Deployment validation failed"
fi

echo ""
echo "💡 For detailed testing, run: bundle exec rspec spec/acceptance/"
echo ""

exit $exit_code
