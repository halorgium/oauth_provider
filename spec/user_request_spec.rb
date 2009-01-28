describe "A User Request" do
  it "can be authorized" do
    provider = create_provider
    consumer = provider.add_consumer("foo")
    user_request = consumer.issue_request
    user_request.authorize
    consumer.find_user_request(user_request.shared_key).should be_authorized
  end

  describe "which has been authorized" do
    it "can be upgraded" do
      provider = create_provider
      consumer = provider.add_consumer("foo")
      user_request = consumer.issue_request
      user_request.authorize
      user_access = user_request.upgrade
      consumer.find_user_access(user_access.shared_key).should == user_access
    end

    it "can be upgraded with a custom token" do
      provider = create_provider
      consumer = provider.add_consumer("foo")
      user_request = consumer.issue_request(true)
      user_access = user_request.upgrade(OAuthProvider::Token.new("shared key", "secret key"))
      user_access.shared_key.should == "shared key"
      user_access.secret_key.should == "secret key"
    end
  end

  describe "which has not been authorized" do
    it "cannot be upgraded" do
      provider = create_provider
      consumer = provider.add_consumer("foo")
      user_request = consumer.issue_request
      lambda { user_request.upgrade }.
        should raise_error(OAuthProvider::UserRequestNotAuthorized)
    end
  end

  describe "which has been upgraded" do
    it "has been destroyed" do
      provider = create_provider
      consumer = provider.add_consumer("foo")
      user_request = consumer.issue_request
      user_request.authorize
      user_request.upgrade

      lambda { consumer.find_user_request(user_request.shared_key) }.
        should raise_error(OAuthProvider::UserRequestNotFound)
    end
  end
end
