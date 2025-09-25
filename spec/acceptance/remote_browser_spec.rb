# frozen_string_literal: true

require 'spec_helper'

# Dedicated remote browser tests - no mocking, tests real deployed app
RSpec.describe 'Remote Horoscope App Browser Tests', type: :feature, js: true do
  before(:all) do
    unless ENV['REMOTE_URL']
      raise "REMOTE_URL environment variable must be set to run remote tests"
    end
  end

  describe 'Remote app functionality' do
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

    it 'allows selecting and submitting horoscope requests' do
      visit '/'
      
      select 'Leo', from: 'zodiac'
      expect(page).to have_select('zodiac', selected: 'Leo')
      
      click_button 'Consultar'
      
      # Wait for results to appear - real API call will take time
      expect(page).to have_css('.results:not(.hidden)', wait: 30)
      expect(page).to have_content('Tu horóscopo', wait: 30)
      expect(page).to have_css('.results:not(.error)')
    end

    it 'handles multiple zodiac sign requests' do
      visit '/'
      
      ['Aries', 'Virgo', 'Piscis'].each do |sign|
        select sign, from: 'zodiac'
        click_button 'Consultar'
        
        # Wait for response
        expect(page).to have_content('Tu horóscopo', wait: 30)
        expect(page).to have_css('.results:not(.error)')
        
        # Small delay between requests
        sleep(1)
      end
    end

    it 'validates empty form submission' do
      visit '/'
      
      # Remove HTML5 required attribute to test JS validation
      page.execute_script("document.getElementById('zodiac').removeAttribute('required');")
      
      click_button 'Consultar'
      
      expect(page).to have_css('.results:not(.hidden)', wait: 5)
      expect(page).to have_content('Error')
      expect(page).to have_content('Por favor selecciona un signo')
      expect(page).to have_css('.results.error')
    end

    it 'has proper accessibility features' do
      visit '/'
      
      expect(page).to have_css('#results[aria-live="polite"]', visible: :all)
      expect(page).to have_css('label[for="zodiac"]')
      expect(page).to have_content('Selecciona tu signo zodiacal:')
    end

    it 'works on different viewport sizes' do
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

    it 'health endpoint is accessible' do
      visit '/health'
      expect(page).to have_content('OK')
    end
  end
end
