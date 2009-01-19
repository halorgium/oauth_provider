require 'rubygems'
require 'spec'
require 'rack'
require 'pp'

require File.dirname(__FILE__) + '/../lib/oauth_provider'

require 'oauth/request_proxy/rack_request'

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

describe "A Provider" do
  before(:each) do
    @provider = OAuthProvider.new(:in_memory)
    consumer = @provider.add_consumer("test consumer", "http://testconsumer.example.org/")
    @client = OAuthClient.new(consumer.shared_key, consumer.secret_key)
  end

  it "issues a token" do
    token = @provider.issue_token(@client.request)
    token.should_not be_authorized
  end

  describe "with a request token" do
    before(:each) do
      @request_token = @provider.issue_token(@client.request)
    end

    it "upgrades the token" do
      request = @client.request(@request_token)
      token = @provider.upgrade_token(request)
      token.should be_authorized
    end

    describe "converted to an access toekn" do
      before(:each) do
        request = @client.request(@request_token)
        @access_token = @provider.upgrade_token(request)
      end

      it "validates the token" do
        request = @client.request(@access_token)
        lambda { @provider.validate_token(request) }.
          should_not raise_error
      end
    end
  end
end
