require File.dirname(__FILE__) + '/spec_helper'

if ENV["DATAMAPPER"]
  require 'dm-core'
  DataMapper.setup(:default, "sqlite3:///tmp/oauth_provider_test.sqlite3")
end

describe "A Provider" do
  describe "adding a consumer" do
    it "saves the consumer" do
      provider = OAuthProvider.create(:in_memory)
      consumer = provider.add_consumer("http://testconsumer.example.org/")
      provider.consumer_for(consumer.shared_key).should == consumer
    end
  end

  describe "with a consumer" do
    before(:each) do
      if ENV["DATAMAPPER"]
        @provider = OAuthProvider::Provider.create(:data_mapper)
        DataMapper.auto_migrate!
      else
        @provider = OAuthProvider.create(:in_memory)
      end
      consumer = @provider.add_consumer("http://testconsumer.example.org/")
      @client = OAuthClient.new(consumer)
    end

    it "issues a user request" do
      user_request = @provider.issue_request(@client.request)
      lambda { @provider.validate_token(@client.request(user_request)) }.
        should raise_error(OAuthProvider::UserAccessNotFound)
      @provider.user_request_for(user_request.shared_key).should_not be_nil
    end

    describe "with a user request" do
      before(:each) do
        @user_request = @provider.issue_request(@client.request)
      end

      it "authorizes the request" do
        @user_request.authorize
        @user_request.user_access.should_not be_nil
      end

      describe "which has been authorized" do
        before(:each) do
          @user_request.authorize
        end

        it "upgrades the request" do
          request = @client.request(@user_request)
          user_access = @provider.upgrade_request(request)
          lambda { @provider.validate_token(@client.request(user_access)) }.
            should_not raise_error
        end

        describe "converted to user access" do
          before(:each) do
            request = @client.request(@user_request)
            @access_token = @provider.upgrade_request(request)
          end

          it "validates the token" do
            request = @client.request(@access_token)
            lambda { @provider.validate_token(request) }.
              should_not raise_error
          end
        end
      end
    end
  end
end
