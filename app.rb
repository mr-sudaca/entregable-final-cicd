# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'openai'
require 'newrelic_rpm'
require 'rack/protection'
require './searcher'

NewRelic::Agent.manual_start(
  license_key: ENV.fetch('NEW_RELIC_KEY', nil),
  app_name: "Horoscopo - #{ENV.fetch('RACK_ENV', 'development')}"
)

# Define the main application class
class App < Sinatra::Base
  enable :sessions
  set :session_secret, ENV.fetch('SESSION_SECRET')
  set :environment, (ENV['RACK_ENV']&.to_sym || :development)

  # In test environment, we relax Rack::Protection to simplify acceptance tests
  if settings.environment == :test
    set :protection, false
  else
    use Rack::Protection
    use Rack::Protection::AuthenticityToken
  end

  get '/' do
    erb :index
  end

  post '/horoscopo' do
    content_type :json
    zodiac = params['zodiac']&.strip

    begin
      { message: Searcher.fetch(zodiac) }.to_json
    rescue StandardError => e
      status 500
      { error: 'Error consultando el horóscopo', details: e.message }.to_json
    end
  end

  get '/health' do
    'OK'
  end
end
