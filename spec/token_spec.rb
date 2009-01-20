describe "A Token" do
  describe "being generated" do
    it "has a shared and secret key" do
      t = OAuthProvider::Token.generate
      t.shared_key.should_not be_nil
      t.secret_key.should_not be_nil
    end
  end

  it "correctly generates the query string" do
    t = OAuthProvider::Token.new("shared", "secret")
    t.query_string.should == "oauth_token=shared&oauth_token_secret=secret"
  end

  it "is equal to another token when both the shared and secret keys match" do
    token1 = OAuthProvider::Token.new("123", "456")
    token2 = OAuthProvider::Token.new("123", "456")
    token1.should == token2
  end
end
