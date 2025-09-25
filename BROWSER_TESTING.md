# Browser Testing Guide

This project includes comprehensive browser-based acceptance tests using Capybara and Selenium WebDriver.

## Test Types

### 1. Local Browser Tests
Tests the application running locally with mocked external dependencies.

```bash
# Run all local browser tests
bundle exec rspec spec/acceptance/browser_spec.rb

# Run specific test
bundle exec rspec spec/acceptance/browser_spec.rb:88
```

### 2. Remote Browser Tests (Approach 1: Configurable)
Uses the same test suite but configured to test against a deployed application.

```bash
# Using the script
./test_remote.sh https://your-app.herokuapp.com

# Or manually
export REMOTE_URL=https://your-app.herokuapp.com
bundle exec rspec spec/acceptance/browser_spec.rb
```

### 3. Remote Browser Tests (Approach 2: Dedicated)
Separate test file specifically designed for remote testing.

```bash
# Using the script
./test_remote_dedicated.sh https://your-app.herokuapp.com

# Or manually
export REMOTE_URL=https://your-app.herokuapp.com
bundle exec rspec spec/acceptance/remote_browser_spec.rb
```

## Test Coverage

### Local Tests (18 tests)
- ✅ App initialization and page loading
- ✅ Form interactions and zodiac sign selection
- ✅ AJAX horoscope submission and response handling
- ✅ Error handling scenarios (with mocking)
- ✅ Accessibility and UX features
- ✅ Responsive design testing
- ✅ Loading state testing (requires mocking)
- ✅ API error simulation (requires mocking)

### Remote Tests
- ✅ App initialization and page loading
- ✅ Form interactions and zodiac sign selection
- ✅ Real AJAX horoscope submission (actual API calls)
- ✅ Basic error handling (form validation)
- ✅ Accessibility and UX features
- ✅ Responsive design testing
- ⚠️ Loading state testing (skipped - can't control timing)
- ⚠️ API error simulation (skipped - can't force errors)

## Configuration

### Environment Variables
- `REMOTE_URL`: When set, configures tests to run against remote URL instead of local app

### Capybara Configuration
- **Local mode**: Uses Puma server with mocked dependencies
- **Remote mode**: Disables local server, points to remote URL
- **Driver**: Chrome headless for CI/CD compatibility
- **Wait time**: 10 seconds for AJAX operations (30 seconds for remote tests)

## Browser Requirements

### Local Development
- Chrome browser installed
- ChromeDriver (automatically managed by selenium-webdriver gem)

### CI/CD Environment
Tests are configured with Chrome options for headless operation:
- `--headless`
- `--no-sandbox`
- `--disable-dev-shm-usage`
- `--disable-gpu`
- `--window-size=1280,720`

## Test Examples

### Testing Local App
```bash
# Run all tests
bundle exec rspec

# Run only browser tests
bundle exec rspec spec/acceptance/browser_spec.rb

# Run with documentation format
bundle exec rspec spec/acceptance/browser_spec.rb --format documentation
```

### Testing Deployed App
```bash
# Test against Heroku app
./test_remote.sh https://your-app.herokuapp.com

# Test against Netlify app
./test_remote.sh https://your-app.netlify.app

# Test against custom domain
./test_remote.sh https://horoscope.yourdomain.com
```

## Troubleshooting

### Chrome Issues
If you encounter Chrome-related errors:
```bash
# Update Chrome and ChromeDriver
brew update && brew upgrade google-chrome chromedriver
```

### Timeout Issues
For slow networks or APIs, increase wait times:
```ruby
# In spec_helper.rb
Capybara.default_max_wait_time = 30
```

### Remote URL Issues
Ensure your remote URL:
- Is accessible via HTTPS
- Has CORS properly configured
- Returns proper JSON responses
- Has the same endpoints as local app

## Integration with CI/CD

### GitHub Actions Example
```yaml
- name: Run Browser Tests (Local)
  run: bundle exec rspec spec/acceptance/browser_spec.rb

- name: Run Browser Tests (Remote)
  env:
    REMOTE_URL: ${{ secrets.DEPLOYED_APP_URL }}
  run: bundle exec rspec spec/acceptance/browser_spec.rb
```

### GitLab CI Example
```yaml
test_browser_local:
  script:
    - bundle exec rspec spec/acceptance/browser_spec.rb

test_browser_remote:
  variables:
    REMOTE_URL: $DEPLOYED_APP_URL
  script:
    - bundle exec rspec spec/acceptance/browser_spec.rb
```

## Best Practices

1. **Use local tests for development** - faster feedback, full mocking control
2. **Use remote tests for deployment validation** - real environment testing
3. **Run both in CI/CD pipeline** - comprehensive coverage
4. **Monitor test execution time** - remote tests are slower
5. **Handle flaky tests** - network issues can cause intermittent failures
6. **Use appropriate wait times** - balance speed vs reliability
