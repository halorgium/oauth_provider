require 'rubygems'
require 'spec'
require 'rack'
require 'pp'
require 'oauth/helper'

require File.dirname(__FILE__) + '/../lib/oauth_provider'
require File.dirname(__FILE__) + '/helpers/backend_helper'

OAuthBackendHelper.setup

module OAuthProviderHelper
  def create_provider
    OAuthBackendHelper.provider
  end
end

Spec::Runner.configure do |config|
  config.include(OAuthProviderHelper)

  config.before(:each) do
    OAuthBackendHelper.reset
  end
end

require 'oauth/request_proxy/base'

module OAuth
  module RequestProxy
    class MockRequest < OAuth::RequestProxy::Base
      proxies Hash

      def parameters
        @request["parameters"]
      end

      def method
        @request["method"]
      end

      def uri
        @request["uri"]
      end
    end
  end
end

class OAuthClient
  def initialize(consumer)
    @consumer = OAuth::Consumer.new(consumer.shared_key, consumer.secret_key)
  end
  attr_reader :consumer

  def request(token = nil)
    Request.new(@consumer, Time.now.to_i, token).signed_request
  end

  class Request
    include OAuth::Helper

    def initialize(consumer, timestamp, token)
      @consumer, @timestamp, @nonce, @token = consumer, timestamp, generate_key, token
    end

    def signed_request
      r = request
      r["parameters"]["oauth_signature"] = signature
      r
    end

    def signature
      OAuth::Signature.sign(request) do |token|
        [@token && @token.secret_key, @consumer.secret]
      end
    end

    def request
      {"parameters" => query_hash,
        "method" => "GET",
        "uri" => "/"}
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
