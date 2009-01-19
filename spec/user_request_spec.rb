describe "A User Request" do
  it "can be authorized" do
    provider = OAuthProvider::Provider.create(:in_memory)
    consumer = provider.add_consumer("test", "foo")
    client = OAuthClient.new(consumer)
    user_request = provider.issue_request(client.request)
    user_request.authorize
  end
end
