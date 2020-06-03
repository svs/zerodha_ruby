require "zerodha_ruby/version"
require "digest"
require "httparty"
module Zerodha
  class Error < StandardError; end
  class TokenException < Error; end
  class Client


    class Partay
      include HTTParty
      base_uri  "https://api.kite.trade"
      default_options[:headers] = {"X-Kite-Version" => "3"}
      #debug_output
    end

    class API
      def initialize(auth_token)
        @auth_token = auth_token
      end

      def get(path, params = {})
        Partay.get(path, body: params, headers: {"Authorization" => @auth_token})
      end
    end

    def initialize(api_key:, api_secret: nil, request_token: nil, access_token: nil)
      @api_key, @api_secret, @request_token, @access_token = api_key, api_secret, request_token, access_token
    end

    def access_token
      @access_token || get_access_token
    end

    def get(path, params = {})
      d = api_client.get(path, params).parsed_response
      if d["error_type"] == "TokenException"
        raise TokenException
      else
        d
      end
    end

    def instruments
      r = get("/instruments")
    end

    def historical(instrument_token, interval, from, to, continuous = false, oi = false)
      get("/instruments/historical/#{instrument_token}/#{interval}?from=#{from}&to=#{to}&continuous=continuous&oi=oi")["data"]["candles"]
    end

    def quotes(trading_symbol)
      ap trading_symbol
      d = get("/quote?i=#{trading_symbol}")
      d
    end

    def trades
      d = get("/trades")["data"]
    end

    def pending_orders
      get("/orders")["data"].select{|o| o['status'] =~ /PENDING/}
    end

    def user
      get("/user/profile")
    end

    def positions
      get("/portfolio/positions")['data']
    end

    private

    attr_reader :api_key, :api_secret, :request_token, :data

    def api_client
      @api_client ||= API.new("token #{api_key}:#{access_token}")
    end


    def get_access_token
      r = Partay.post("/session/token", body: {api_key: api_key, request_token: request_token, checksum: checksum})
      ap r
      if r["data"]
        @data ||= r["data"]
        @access_token = @data["access_token"]
      else
        raise
      end
    end

    def checksum
      Digest::SHA256.hexdigest api_key + request_token + api_secret
    end

  end


end
