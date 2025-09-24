# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'openai'
require 'rack/protection'
require './searcher'

# Define the main application class
class App < Sinatra::Base
  enable :sessions
  set :session_secret, ENV.fetch('SESSION_SECRET')

  use Rack::Protection
  use Rack::Protection::AuthenticityToken

  get '/' do
    erb :index
  end

  post '/horoscopo' do
    content_type :json
    zodiac = params['zodiac']&.strip

    { message: Searcher.fetch(zodiac) }.to_json
  end
end
