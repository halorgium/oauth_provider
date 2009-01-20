require File.dirname(__FILE__) + '/spec_helper'

describe "A Provider" do
  describe "adding a consumer" do
    it "saves the consumer" do
      provider = create_provider
      consumer = provider.add_consumer("http://testconsumer.example.org/")
      provider.find_consumer(consumer.shared_key).should == consumer
    end
  end

  describe "fetching all the consumers" do
    it "returns the complete list" do
      provider = create_provider
      one = provider.add_consumer("http://one.com/")
      two = provider.add_consumer("http://two.com/")
      provider.consumers.should == [one, two]
    end
  end

  describe "deleting a consumer" do
    it "removes the consumer from the backend" do
      provider = create_provider
      one = provider.add_consumer("http://one.com/")
      provider.destroy_consumer(one)
      provider.consumers.should be_empty
    end
  end

  describe "with a consumer" do
    before(:each) do
      @provider = create_provider
      @consumer = @provider.add_consumer("http://testconsumer.example.org/")
      @client = OAuthClient.new(@consumer)
    end

    it "issues a user request" do
      user_request = @provider.issue_request(@client.request)
      lambda { @provider.confirm_access(@client.request(user_request)) }.
        should raise_error(OAuthProvider::UserAccessNotFound)
      @consumer.find_user_request(user_request.shared_key).should_not be_nil
    end

    describe "with a user request" do
      before(:each) do
        @user_request = @provider.issue_request(@client.request)
      end

      it "authorizes the request" do
        @user_request.authorize
        @user_request.should be_authorized
      end

      describe "which has been authorized" do
        before(:each) do
          @user_request.authorize
        end

        it "upgrades the request" do
          request = @client.request(@user_request)
          user_access = @provider.upgrade_request(request)
          lambda { @provider.confirm_access(@client.request(user_access)) }.
            should_not raise_error
        end

        describe "converted to user access" do
          before(:each) do
            request = @client.request(@user_request)
            @access_token = @provider.upgrade_request(request)
          end

          it "validates the token" do
            request = @client.request(@access_token)
            @provider.confirm_access(request)
            lambda { @provider.confirm_access(request) }.
              should_not raise_error
          end
        end
      end
    end
  end
end
