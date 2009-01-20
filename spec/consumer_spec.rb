describe "A Consumer" do
  it "issues the user request" do
    provider = create_provider
    consumer = provider.add_consumer("http://foo.com")
    consumer.issue_request.should_not be_nil
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
