describe "A Consumer" do
  describe "issuing a user request" do
    it "saves the request" do
      provider = create_provider
      consumer = provider.add_consumer("http://foo.com")
      user_request = consumer.issue_request
      consumer.find_user_request(user_request.shared_key).should == user_request
    end

    describe "specifying that it is already authorized" do
      it "is authorized" do
        provider = create_provider
        consumer = provider.add_consumer("http://foo.com")
        user_request = consumer.issue_request(true)
        consumer.find_user_request(user_request.shared_key).should be_authorized
      end
    end

    describe "specifying that it is not authorized" do
      it "is not authorized" do
        provider = create_provider
        consumer = provider.add_consumer("http://foo.com")
        user_request = consumer.issue_request(false)
        consumer.find_user_request(user_request.shared_key).should_not be_authorized
      end
    end

    describe "with a custom token" do
      it "uses the provided token" do
        provider = create_provider
        consumer = provider.add_consumer("http://foo.com")
        user_request = consumer.issue_request(false, OAuthProvider::Token.new("shared key", "secret key"))
        consumer.find_user_request("shared key").should == user_request
        user_request.secret_key.should == "secret key"
      end
    end
  end

  it "finds the same user access for a shared key" do
    provider = create_provider
    consumer = provider.add_consumer("http://foo.com")
    user_request = consumer.issue_request
    user_request.authorize
    user_access = user_request.upgrade
    consumer.find_user_access(user_access.shared_key).should == user_access
  end

  it "is equal to another consumer when both the callback and token match" do
    provider = create_provider
    token1 = OAuthProvider::Token.new("123", "456")
    token2 = OAuthProvider::Token.new("123", "456")
    consumer1 = OAuthProvider::Consumer.new(nil, provider, "callback", token1)
    consumer2 = OAuthProvider::Consumer.new(nil, provider, "callback", token2)
    consumer1.should == consumer2
  end
end
