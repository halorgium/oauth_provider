describe "A User Access" do
  it "stores the User Request shared_key" do
    provider = create_provider
    consumer = provider.add_consumer("foo")
    user_request = consumer.issue_request
    user_request.authorize
    user_access = user_request.upgrade
    user_access.request_shared_key.should == user_request.shared_key
  end
end
