require 'rubygems'
require 'spec'
require 'rack'
require 'pp'

require File.dirname(__FILE__) + '/../lib/oauth_provider'

require 'oauth/request_proxy/rack_request'

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
