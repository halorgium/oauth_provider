describe "A Consumer" do
  it "issues the user request" do
    provider = create_provider
    consumer = provider.add_consumer("http://foo.com")
    consumer.issue_request.should_not be_nil
  end

  it "finds the same user request for a shared key" do
    provider = create_provider
    consumer = provider.add_consumer("http://foo.com")
    user_request = consumer.issue_request
    consumer.find_user_request(user_request.shared_key).should == user_request
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
