# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'openai'
require 'rack/protection'

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
    client = OpenAI::Client.new(access_token: ENV.fetch('CHATGPT_KEY'), uri_base: 'https://api.groq.com/openai')
    zodiac = params['zodiac']&.strip

    response = client.chat(
      parameters: {
        model: 'meta-llama/llama-4-maverick-17b-128e-instruct',
        messages: [
          {
            role: 'user',
            content: "puedes consultar el horóscopo del día de hoy para el
                      signo #{zodiac.downcase}?, no me des sugerencias, solo
                      una descripción del horoscopo para el día de hoy"
          }
        ],
        temperature: 0.7
      }
    )

    message = if response['choices']
                "Tu horóscopo para #{zodiac.capitalize}: #{response.dig('choices', 0, 'message', 'content')}"
              else
                'Lo siento, no pude obtener tu horóscopo en este momento.'
              end

    { message: message }.to_json
  end
end
