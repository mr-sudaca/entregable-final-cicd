# Smoke Testing Guide

Smoke tests are minimal, fast tests that verify the core functionality of your application is working. They're perfect for quick deployment validation and CI/CD pipelines.

## What are Smoke Tests?

Smoke tests answer the question: **"Is the application basically working?"**

They test the critical path through your application with minimal overhead:
- ✅ Application loads
- ✅ Core functionality works
- ✅ No major errors
- ❌ Don't test edge cases
- ❌ Don't test complex scenarios

## Our Smoke Test Suite

Located in `spec/smoke/smoke_test_spec.rb`, our smoke tests cover:

### Critical Path Tests (Must Pass)
1. **Application loads and displays main page**
   - Homepage renders correctly
   - All essential UI elements present
   - Form and controls available

2. **Form submission works end-to-end**
   - Can select zodiac sign
   - Form submits successfully
   - Gets response without errors

3. **Health endpoint responds**
   - `/health` endpoint returns "OK"
   - Basic server health verification

### Basic Functionality Checks
4. **Zodiac options are available**
   - Key zodiac signs present in dropdown
   - Form options populated correctly

5. **Form validation works**
   - Empty form submission shows error
   - Client-side validation functioning

6. **UI responsiveness check**
   - Works on mobile viewport
   - Basic responsive design functioning

## Usage

### Local Testing
```bash
# Run smoke tests against local app
./smoke_test.sh

# Or directly with RSpec
bundle exec rspec spec/smoke/smoke_test_spec.rb
```

### Remote Testing
```bash
# Run smoke tests against deployed app
./smoke_test.sh https://your-app.herokuapp.com

# Or with environment variable
REMOTE_URL=https://your-app.com bundle exec rspec spec/smoke/smoke_test_spec.rb
```

## Execution Time

- **Local**: ~3-5 seconds
- **Remote**: ~10-15 seconds

Compare this to full test suite:
- **Full browser tests**: ~20-60 seconds
- **All tests**: ~30-90 seconds

## Integration with CI/CD

### GitHub Actions
```yaml
name: Smoke Tests
on: [push, deployment]

jobs:
  smoke-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true
      - name: Run Smoke Tests
        run: ./smoke_test.sh ${{ secrets.DEPLOYED_APP_URL }}
```

### GitLab CI
```yaml
smoke_test:
  stage: test
  script:
    - ./smoke_test.sh $DEPLOYED_APP_URL
  only:
    - main
    - develop
```

### Post-Deployment Hook
```bash
#!/bin/bash
# deploy-hook.sh
echo "Deployment completed, running smoke tests..."
./smoke_test.sh https://your-app.com
if [ $? -eq 0 ]; then
    echo "✅ Deployment validated successfully"
    # Send success notification
else
    echo "❌ Deployment validation failed"
    # Send alert, rollback, etc.
    exit 1
fi
```

## When to Use Smoke Tests

### ✅ Perfect For:
- **Post-deployment validation**
- **Quick health checks**
- **CI/CD pipeline gates**
- **Monitoring/alerting**
- **Pre-release verification**
- **Environment validation**

### ❌ Not Suitable For:
- **Comprehensive testing**
- **Edge case validation**
- **Performance testing**
- **Security testing**
- **Complex user journeys**

## Test Strategy

```
Development Cycle:
┌─────────────────┐    ┌──────────────┐    ┌─────────────┐
│   Unit Tests    │ -> │ Smoke Tests  │ -> │ Full E2E    │
│   (Fast)        │    │  (Quick)     │    │ (Thorough)  │
│   Every change  │    │  Pre-deploy  │    │ Pre-release │
└─────────────────┘    └──────────────┘    └─────────────┘
```

## Customization

### Adding New Smoke Tests
```ruby
it 'new critical feature works' do
  visit '/'
  
  # Test the absolute minimum to verify it works
  expect(page).to have_selector('#new-feature')
  click_button 'New Feature'
  expect(page).not_to have_css('.error')
end
```

### Environment-Specific Tests
```ruby
it 'production-specific feature' do
  skip 'Only for production' unless ENV['REMOTE_URL']&.include?('production')
  
  # Test production-only features
end
```

### Custom Timeouts
```ruby
# Adjust timeouts based on environment
timeout = case ENV['REMOTE_URL']
when /staging/ then 20
when /production/ then 30
else 10
end

expect(page).to have_content('Result', wait: timeout)
```

## Monitoring Integration

### Datadog/New Relic
```bash
# Report smoke test results to monitoring
if ./smoke_test.sh https://production.app.com; then
    curl -X POST "https://api.datadoghq.com/api/v1/events" \
         -H "DD-API-KEY: $DD_API_KEY" \
         -d '{"title":"Smoke Tests Passed","text":"Production deployment validated"}'
else
    curl -X POST "https://api.datadoghq.com/api/v1/events" \
         -H "DD-API-KEY: $DD_API_KEY" \
         -d '{"title":"Smoke Tests Failed","text":"Production deployment validation failed","alert_type":"error"}'
fi
```

### Slack Notifications
```bash
# Send results to Slack
if ./smoke_test.sh https://app.com; then
    curl -X POST -H 'Content-type: application/json' \
         --data '{"text":"✅ Smoke tests passed for deployment"}' \
         $SLACK_WEBHOOK_URL
else
    curl -X POST -H 'Content-type: application/json' \
         --data '{"text":"❌ Smoke tests failed for deployment"}' \
         $SLACK_WEBHOOK_URL
fi
```

## Best Practices

1. **Keep it minimal** - Only test critical functionality
2. **Make it fast** - Should complete in under 30 seconds
3. **Make it reliable** - Should rarely fail due to flakiness
4. **Test the happy path** - Focus on core user journey
5. **Use appropriate timeouts** - Account for network latency
6. **Fail fast** - Use `--fail-fast` to stop on first failure
7. **Clear reporting** - Make results easy to understand

## Troubleshooting

### Common Issues

**Timeout errors on remote tests:**
```ruby
# Increase timeout for remote environments
timeout = ENV['REMOTE_URL'] ? 30 : 10
expect(page).to have_content('Result', wait: timeout)
```

**Flaky network issues:**
```ruby
# Add retry logic for critical assertions
retries = 0
begin
  expect(page).to have_content('Result')
rescue RSpec::Expectations::ExpectationNotMetError
  retries += 1
  retry if retries < 3
  raise
end
```

**Environment-specific failures:**
```ruby
# Skip tests that don't apply to certain environments
skip 'Local only test' if ENV['REMOTE_URL']
skip 'Production only test' unless ENV['REMOTE_URL']&.include?('production')
```
