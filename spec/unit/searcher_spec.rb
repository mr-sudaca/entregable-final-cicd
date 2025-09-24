# frozen_string_literal: true

require 'spec_helper'
require_relative '../../searcher'

RSpec.describe Searcher do
  describe '#initialize' do
    it 'debería inicializar el cliente OpenAI correctamente' do
    # Arrange (Preparar)
    allow(ENV).to receive(:fetch).with('CHATGPT_KEY').and_return('fake-api-key')

    # Act (Actuar)
    searcher = Searcher.new

    # Assert (Afirmar)
    expect(searcher.instance_variable_get(:@client)).to be_a(OpenAI::Client)
    end
  end

  describe '#fetch' do
    let(:mock_client) { instance_double(OpenAI::Client) }
    let(:searcher) { Searcher.new }
    
    before do
        allow(ENV).to receive(:fetch).with('CHATGPT_KEY').and_return('fake-api-key')
        allow(OpenAI::Client).to receive(:new).and_return(mock_client)
        searcher.instance_variable_set(:@client, mock_client)
    end

    context 'cuando la API responde correctamente' do
        it 'debería devolver el horóscopo formateado' do
        # Arrange
        zodiac = 'aries'
        api_response = {
            'choices' => [
            {
                'message' => {
                'content' => 'Hoy será un día excelente para ti'
                }
            }
            ]
        }
        
        allow(mock_client).to receive(:chat).and_return(api_response)
        
        # Act
        result = searcher.fetch(zodiac)
        
        # Assert
        expected_message = "Tu horóscopo para Aries: Hoy será un día excelente para ti"
        expect(result).to eq(expected_message)
        end
    end

    context 'cuando la API falla' do
        it 'debería devolver un mensaje de error' do
        # Arrange
        zodiac = 'leo'
        api_response = {} # Respuesta vacía = fallo
        
        allow(mock_client).to receive(:chat).and_return(api_response)
        
        # Act
        result = searcher.fetch(zodiac)
        
        # Assert
        expect(result).to eq('Lo siento, no pude obtener tu horóscopo en este momento.')
        end
      end
    end
end
