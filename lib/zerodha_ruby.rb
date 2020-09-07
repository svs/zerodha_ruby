require "zerodha_ruby/version"
require "digest"
require "httparty"
module Zerodha
  class Error < StandardError; end
  class AccessTokenException < Error; end
  class RefreshTokenException < Error; end
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
        ap path
        ap params
        ap @auth_token
        Partay.get(path, body: params, headers: {"Authorization" => @auth_token}).tap{|d|
          if d.is_a?(Hash) && d["status"] == "error"
            ap d
          end
        }
      end

      def post(path, params = {}, headers={})
        Partay.post(path, body: params, headers: headers.merge({"Authorization" => @auth_token}))
      end
    end

    def initialize(api_key:, api_secret: nil, request_token: nil, access_token: nil, refresh_token: nil)
      @api_key, @api_secret, @request_token, @access_token, @refresh_token = api_key, api_secret, request_token, access_token, refresh_token
    end

    def access_token
      @access_token || get_access_token
    end

    def refresh_token
      @refresh_token
    end

    def set_request_token(rt)
      #ap "RESET REQUEST TOKEN"
      @request_token = rt
      @access_token = nil
      get_access_token
    end



    def get(path, params = {})
      d = api_client.get(path, params)
      d = d.parsed_response
      #ap d
      if d.is_a?(Hash) && d["error_type"] == "TokenException"
        raise AccessTokenException
      else
        d
      end
    end

    def post(path, params, headers = {})
      api_client.post(path, params, headers)
    end

    def instruments
      r = get("/instruments")
    end

    def margin(data)
      post("/margins/orders", [data].to_json, {'Content-Type' => "application/json"})
    end

    def user_margin()
      get("/user/margins")

    end

    def margins(which="futures")
      get("/margins/#{which}")
    end

    def place_order(variety, order_data)
      post("/orders/#{variety}", order_data)
    end

    def historical(instrument_token, interval, from, to, continuous = 1, oi = 0)
      # ap instrument_token

      d = get("/instruments/historical/#{instrument_token}/#{interval}?from=#{from}&to=#{to}&continuous=#{continuous}&oi=#{oi}")
      ap d unless d["data"]
      d["data"]["candles"]
    end

    def quotes(exchange_token, ohlc = false)
      qs = Array(exchange_token).map{|t| "i=#{t}"}.join("&")
      ap qs
      if ohlc
        d = get("/quote/ohlc?#{qs}")
      else
        d = get("/quote?#{qs}")
      end
      d["data"]
    end


    def orders(order_id = nil)
      if order_id
        get("/orders/#{order_id}")["data"]
      else
        get("/orders")["data"]
      end
    end

    def trades
      r = get("/trades")
      d = r["data"]
      if !d
        #ap r
        nil
      else
        d
      end
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

    def holdings
      get("/portfolio/holdings")['data']
    end

    def refresh_access_token
      #ap "getting REFRESH TOKEN with #{refresh_checksum}"
      @api_client = nil
      @access_token = nil
      r = Partay.post("/session/refresh_token", body: {api_key: api_key, refresh_token: refresh_token, checksum: refresh_checksum})
      #ap r
      if r["data"]
        #ap r["data"]
        @data ||= r["data"]
        @refresh_token = @data["refresh_token"]
        @access_token = @data["access_token"]
      else
        raise RefreshTokenException
      end
      return @access_token
    end


    private

    attr_reader :api_key, :api_secret, :request_token, :data

    def api_client
      @api_client ||= API.new("token #{api_key}:#{access_token}")
    end



    def get_access_token
      #ap "Getting ACCESS TOKEN with checksum #{checksum}"

      r = Partay.post("/session/token", body: {api_key: api_key, request_token: request_token, checksum: checksum})
      if r["data"]
        #ap r["data"]
        @data ||= r["data"]
        @refresh_token = @data["refresh_token"]
        @access_token = @data["access_token"]
      else
        #ap r
        raise AccessTokenException
      end
      return @access_token
    end


    def checksum
      #ap "CHECKSUM for #{api_key} #{request_token} #{api_secret}"
      begin
        Digest::SHA256.hexdigest api_key + request_token + api_secret
      rescue Exception => e
        raise AccessTokenException
      end
    end

    def refresh_checksum
      #ap "CHECKSUM for #{api_key} #{refresh_token} #{api_secret}"
      begin
        Digest::SHA256.hexdigest api_key + refresh_token + api_secret
      rescue Exception => e
        raise RefreshTokenException
      end
    end
  end



end
