# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

RSpec.describe 'App acceptance', type: :request do
  include Rack::Test::Methods

  def app
    App
  end

  let(:csrf_token) { "test-csrf-token-1234567890" }

  describe "GET /" do
    it "returns 200 and renders the horoscope form" do
      get "/"

      expect(last_response.status).to eq(200)
      expect(last_response.headers["Content-Type"]).to include("text/html")
      expect(last_response.body).to include("Horóscopo")
      expect(last_response.body).to include("<form id=\"horoscope-form\"")
    end
  end

  describe "POST /horoscopo" do
    context "with valid CSRF token" do
      it "returns JSON with message from Searcher" do
        # Stub the external searcher call to avoid hitting API
        allow(Searcher).to receive(:fetch).with("leo").and_return("Tu horóscopo fake para Leo")

        post "/horoscopo", { zodiac: "leo" },
             { "HTTP_ACCEPT" => "application/json" }

        expect(last_response.status).to eq(200)
        expect(last_response.headers["Content-Type"]).to include("application/json")

        body = JSON.parse(last_response.body)
        expect(body).to include("message")
        expect(body["message"]).to include("Tu horóscopo fake para Leo")
      end
    end

    context "without CSRF token" do
      it "still returns 200 and JSON (protection disabled in test)" do
        allow(Searcher).to receive(:fetch).with("leo").and_return("Tu horóscopo fake para Leo")
        post "/horoscopo", { zodiac: "leo" }, { "HTTP_ACCEPT" => "application/json" }
        expect(last_response.status).to eq(200)
        body = JSON.parse(last_response.body)
        expect(body).to include("message")
      end
    end
  end
end
