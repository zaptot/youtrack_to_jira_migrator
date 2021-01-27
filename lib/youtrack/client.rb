# frozen_string_literal: true

module Youtrack
  class Client
    attr_reader :youtrack_url, :token

    def initialize(url, token)
      @youtrack_url = URI.join(url, 'api/')
      @token = token
    end

    def get(path, params: nil)
      Rails.logger.info("YOUTRACK CLIENT REQUEST: path: #{path}, params: #{params}")
      curl = Curl::Easy.new(generate_url(path, params).to_s)
      curl.headers = headers
      curl.timeout = 200
      curl.perform
      validate_response(curl)

      curl
    end

    private

    def generate_url(path, params)
      url = URI.join(youtrack_url, File.join(path))
      url.query = URI.encode_www_form(params) if params
      url
    end

    def validate_response(curl)
      return if (200..204).include?(curl.response_code)

      Rails.logger.info curl.body_str
      raise 'bad request'
    end

    def headers
      {
        'Accept' => 'application/json',
        'Authorization' => "Bearer #{token}",
        'Cache-Control' => 'no-cache',
        'Content-Type' => 'application/json'
      }
    end
  end
end
