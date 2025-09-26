# frozen_string_literal: true

require 'spec_helper'

# Minimal smoke tests for quick deployment validation
# These tests verify core functionality is working without extensive testing
RSpec.describe 'Horoscope App Smoke Tests', type: :feature, js: true do
  before(:all) do
    # Smoke tests should work for both local and remote
    if ENV['REMOTE_URL']
      puts "💨 Running smoke tests against remote URL: #{ENV['REMOTE_URL']}"
    else
      puts "💨 Running smoke tests against local app"
    end
  end

  before(:each) do
    # For local testing, provide a simple mock to avoid API calls
    unless ENV['REMOTE_URL']
      allow(Searcher).to receive(:fetch) do |sign|
        "Tu horóscopo para #{sign}: Todo saldrá bien hoy."
      end
    end
  end

  describe 'Critical path smoke tests' do
    it 'application loads and displays main page' do
      visit '/'
      
      # Basic page structure
      expect(page).to have_title('AstroGPT')
      expect(page).to have_content('AstroGPT')
      expect(page).to have_selector('form#horoscope-form')
      expect(page).to have_selector('select#zodiac')
      expect(page).to have_button('Consultar')
    end

    it 'form submission works end-to-end' do
      visit '/'
      
      # Select a zodiac sign and submit
      select 'Leo', from: 'zodiac'
      click_button 'Consultar'
      
      # Verify response appears (allow extra time for remote)
      timeout = ENV['REMOTE_URL'] ? 30 : 10
      expect(page).to have_css('.results:not(.hidden)', wait: timeout)
      
      # For smoke tests, just verify we get some content and no error
      if ENV['REMOTE_URL']
        # Remote: just check we got a response without error
        expect(page).not_to have_css('.results.error')
        expect(page).to have_css('.results')
      else
        # Local: check for our mocked response
        expect(page).to have_content('Tu horóscopo para leo')
        expect(page).not_to have_css('.results.error')
      end
    end

    it 'health endpoint responds' do
      visit '/health'
      expect(page).to have_content('OK')
    end
  end

  describe 'Basic functionality checks' do
    it 'zodiac options are available' do
      visit '/'
      
      # Check a few key zodiac signs are present
      %w[Leo Aries Virgo].each do |sign|
        expect(page).to have_css("select#zodiac option", text: sign)
      end
    end

    it 'form validation works' do
      visit '/'
      
      # Remove HTML5 validation to test JS validation
      page.execute_script("document.getElementById('zodiac').removeAttribute('required');")
      
      # Submit empty form
      click_button 'Consultar'
      
      # Should show validation error
      expect(page).to have_css('.results:not(.hidden)', wait: 5)
      expect(page).to have_content('Error')
      expect(page).to have_css('.results.error')
    end
  end

  describe 'UI responsiveness check' do
    it 'works on mobile viewport' do
      # Test mobile size
      page.driver.browser.manage.window.resize_to(375, 667)
      visit '/'
      
      # Basic elements should still be present
      expect(page).to have_content('AstroGPT')
      expect(page).to have_selector('form#horoscope-form')
      
      # Reset to desktop
      page.driver.browser.manage.window.resize_to(1280, 720)
    end
  end
end
