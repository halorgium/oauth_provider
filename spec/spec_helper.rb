require 'rubygems'
require 'spec'
require 'rack'
require 'pp'

require File.dirname(__FILE__) + '/../lib/oauth_provider'

class OAuthClient
  def initialize(shared_key, secret_key)
    @consumer = OAuth::Consumer.new(shared_key, secret_key)
  end
  attr_reader :consumer

  def request(token_shared_key = nil)
    request = Request.new(@consumer, Time.now.to_i, token_shared_key)
    Rack::Request.new(request.signed_env)
  end

  class Request
    include OAuth::Helper

    def initialize(consumer, timestamp, token)
      @consumer, @timestamp, @nonce, @token = consumer, timestamp, generate_key, token
    end

    def signed_env
      unsigned_request = Rack::Request.new(env)
      signature = OAuth::Signature.sign(unsigned_request) do |token|
        [@token && @token.secret_key, @consumer.secret]
      end
      env('oauth_signature' => signature)
    end

    def env(extra_hash = {})
      Rack::MockRequest.env_for("/?#{query_string(extra_hash)}")
    end

    def query_string(extra_hash = {})
      query_hash.merge(extra_hash).map {|k,v| "#{escape(k)}=#{escape(v)}"}.join("&")
    end

    def query_hash
      h = {"oauth_nonce" => @nonce,
           "oauth_timestamp" => @timestamp,
           "oauth_signature_method" => "HMAC-SHA1",
           "oauth_consumer_key" => @consumer.key,
           "oauth_version" => "1.0"}
      h["oauth_token"] = @token.shared_key if @token
      h
    end
  end
end
