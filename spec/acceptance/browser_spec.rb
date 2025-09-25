# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Horoscope App Browser Tests', type: :feature, js: true do
  before(:each) do
    # Stub the external searcher call to avoid hitting API during tests
    allow(Searcher).to receive(:fetch) do |sign|
      sleep(0.5) # Add small delay to simulate API call
      "Tu horóscopo de prueba para #{sign}."
    end
  end

  describe 'App initialization and page loading' do
    it 'loads the homepage successfully' do
      visit '/'
      
      expect(page).to have_title('Horoscopo')
      expect(page).to have_content('Horóscopo')
      expect(page).to have_selector('form#horoscope-form')
      expect(page).to have_selector('select#zodiac')
      expect(page).to have_button('Consultar')
    end

    it 'displays all zodiac sign options' do
      visit '/'
      
      zodiac_signs = [
        'Aries', 'Tauro', 'Géminis', 'Cáncer', 'Leo', 'Virgo',
        'Libra', 'Escorpio', 'Sagitario', 'Capricornio', 'Acuario', 'Piscis'
      ]
      
      zodiac_signs.each do |sign|
        expect(page).to have_css("select#zodiac option", text: sign)
      end
    end

    it 'has proper CSS styling applied' do
      visit '/'
      
      # Check that the container exists and is visible
      expect(page).to have_css('.container')
      
      # Check form elements are visible
      expect(page).to have_css('form#horoscope-form')
      expect(page).to have_css('select#zodiac')
      expect(page).to have_css('button[type="submit"]')
    end
  end

  describe 'Form interactions and zodiac sign selection' do
    it 'allows selecting a zodiac sign' do
      visit '/'
      
      select 'Leo', from: 'zodiac'
      expect(page).to have_select('zodiac', selected: 'Leo')
    end

    it 'shows validation error when no sign is selected' do
      visit '/'
      
      # Remove HTML5 required attribute to test our custom JS validation
      page.execute_script("document.getElementById('zodiac').removeAttribute('required');")
      
      click_button 'Consultar'
      
      # Wait for the error message to appear and become visible
      expect(page).to have_css('.results:not(.hidden)', wait: 5)
      expect(page).to have_content('Por favor selecciona un signo')
      expect(page).to have_css('.results.error')
    end

    it 'can select different zodiac signs' do
      visit '/'
      
      # Test multiple selections
      ['Aries', 'Virgo', 'Piscis'].each do |sign|
        select sign, from: 'zodiac'
        expect(page).to have_select('zodiac', selected: sign)
      end
    end
  end

  describe 'AJAX horoscope submission and response handling' do
    it 'submits form via AJAX and displays horoscope result' do
      visit '/'
      
      select 'Leo', from: 'zodiac'
      click_button 'Consultar'
      
      # Wait for results to appear (skip loading check as it's too fast)
      expect(page).to have_css('.results:not(.hidden)', wait: 10)
      expect(page).to have_content('Tu horóscopo', wait: 10)
      expect(page).to have_content('Tu horóscopo de prueba para leo.')
      expect(page).to have_css('.results:not(.error)')
    end

    it 'displays loading state during AJAX request' do
      visit '/'
      
      select 'Aries', from: 'zodiac'
      
      # Use a longer delay for this specific test
      allow(Searcher).to receive(:fetch) do |sign|
        sleep(2) # Longer delay to catch loading state
        "Tu horóscopo de prueba para #{sign}."
      end
      
      click_button 'Consultar'
      
      # Check that loading message appears
      expect(page).to have_css('.results:not(.hidden)', wait: 1)
      expect(page).to have_content('Consultando...', wait: 1)
      expect(page).to have_content('Obteniendo tu horóscopo para Aries')
    end

    it 'handles multiple consecutive requests' do
      visit '/'
      
      # First request
      select 'Leo', from: 'zodiac'
      click_button 'Consultar'
      expect(page).to have_content('Tu horóscopo', wait: 10)
      expect(page).to have_content('Tu horóscopo de prueba para leo.')
      
      # Second request with different sign
      select 'Virgo', from: 'zodiac'
      click_button 'Consultar'
      expect(page).to have_content('Tu horóscopo', wait: 10)
      expect(page).to have_content('Tu horóscopo de prueba para virgo.')
    end

    it 'preserves form state after successful submission' do
      visit '/'
      
      select 'Sagitario', from: 'zodiac'
      click_button 'Consultar'
      
      # Wait for response
      expect(page).to have_content('Tu horóscopo', wait: 10)
      expect(page).to have_content('Tu horóscopo de prueba para sagitario.')
      
      # Check that the selected option is still selected
      expect(page).to have_select('zodiac', selected: 'Sagitario')
    end
  end

  describe 'Error handling scenarios' do
    context 'when API returns an error' do
      before do
        allow(Searcher).to receive(:fetch).and_raise(StandardError.new('API Error'))
      end

      it 'displays error message when horoscope fetch fails' do
        visit '/'
        
        select 'Leo', from: 'zodiac'
        click_button 'Consultar'
        
        # Should show error state
        expect(page).to have_css('.results:not(.hidden)', wait: 10)
        expect(page).to have_content('Error', wait: 10)
        expect(page).to have_css('.results.error')
      end
    end

    it 'handles empty form submission gracefully' do
      visit '/'
      
      # Remove HTML5 required attribute to test our custom JS validation
      page.execute_script("document.getElementById('zodiac').removeAttribute('required');")
      
      # Try to submit without selecting anything
      click_button 'Consultar'
      
      expect(page).to have_css('.results:not(.hidden)', wait: 5)
      expect(page).to have_content('Error')
      expect(page).to have_content('Por favor selecciona un signo')
      expect(page).to have_css('.results.error')
    end

    it 'recovers from error state when valid request is made' do
      visit '/'
      
      # Remove HTML5 required attribute to test our custom JS validation
      page.execute_script("document.getElementById('zodiac').removeAttribute('required');")
      
      # First, trigger an error
      click_button 'Consultar'
      expect(page).to have_css('.results.error', wait: 5)
      
      # Reset the mock to return success
      allow(Searcher).to receive(:fetch) do |sign|
        sleep(0.5)
        "Tu horóscopo de prueba para #{sign}."
      end
      
      # Then make a valid request
      select 'Leo', from: 'zodiac'
      click_button 'Consultar'
      
      # Should recover and show success
      expect(page).to have_content('Tu horóscopo', wait: 10)
      expect(page).to have_css('.results:not(.error)')
    end
  end

  describe 'Accessibility and UX features' do
    it 'has proper ARIA attributes for screen readers' do
      visit '/'
      
      # Check for aria-live region (it might be hidden initially)
      expect(page).to have_css('#results[aria-live="polite"]', visible: :all)
    end

    it 'has proper form labels and structure' do
      visit '/'
      
      expect(page).to have_css('label[for="zodiac"]')
      expect(page).to have_content('Selecciona tu signo zodiacal:')
      expect(page).to have_css('select#zodiac[required]')
    end

    it 'maintains focus management during interactions' do
      visit '/'
      
      # Focus on select element
      find('#zodiac').click
      expect(page).to have_css('#zodiac:focus')
      
      # Select an option and submit
      select 'Leo', from: 'zodiac'
      click_button 'Consultar'
      
      # Form should still be accessible
      expect(page).to have_css('form#horoscope-form')
    end
  end

  describe 'Health endpoint accessibility' do
    it 'can access health endpoint directly' do
      visit '/health'
      expect(page).to have_content('OK')
    end
  end

  describe 'Responsive design and mobile compatibility' do
    it 'works with different viewport sizes' do
      # Test mobile viewport
      page.driver.browser.manage.window.resize_to(375, 667)
      visit '/'
      
      expect(page).to have_content('Horóscopo')
      expect(page).to have_selector('form#horoscope-form')
      
      # Test desktop viewport
      page.driver.browser.manage.window.resize_to(1280, 720)
      visit '/'
      
      expect(page).to have_content('Horóscopo')
      expect(page).to have_selector('form#horoscope-form')
    end
  end
end
