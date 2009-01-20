describe "A Consumer" do
  it "issues the user request" do
    p = OAuthProvider.create(:in_memory)
    c = p.add_consumer("http://foo.com")
    c.issue_request.should_not be_nil
  end
end
