# frozen_string_literal: true

# clase para manejar la búsqueda del horóscopo
class Searcher
  def initialize
    @client = OpenAI::Client.new(access_token: ENV.fetch('CHATGPT_KEY'), uri_base: 'https://api.groq.com/openai')
  end

  def self.fetch(zodiac)
    new.fetch(zodiac)
  end

  def fetch(zodiac)
    response = @client.chat(parameters: search_params(zodiac))

    if response['choices']
      "Tu horóscopo para #{zodiac.capitalize}: #{response.dig('choices', 0, 'message', 'content')}"
    else
      'Lo siento, no pude obtener tu horóscopo en este momento.'
    end
  end

  private

  def search_params(zodiac)
    {
      model: 'meta-llama/llama-4-maverick-17b-128e-instruct',
      messages: [
        {
          role: 'user', content: "puedes consultar el horóscopo del día de hoy para el
                    signo #{zodiac.downcase}?, no me des sugerencias, solo
                    una descripción del horoscopo para el día de hoy"
        }
      ], temperature: 0.7
    }
  end
end
