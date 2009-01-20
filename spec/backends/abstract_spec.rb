describe "The Abstract backend" do
  %w( create_consumer find_consumer save_consumer destroy_consumer
      create_user_request find_user_request save_user_request destroy_user_request
      create_user_access find_user_access destroy_user_access ).each do |method_name|
    it "does not implement the ##{method_name} method" do
      backend = OAuthProvider::Backends::Abstract.new
      lambda { backend.send(method_name, :arg) }.
        should raise_error(OAuthProvider::NotImplemented, /#{method_name}/)
    end
  end
end
