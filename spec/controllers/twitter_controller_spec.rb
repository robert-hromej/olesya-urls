require "spec_helper"

# todo COMMENTS!
describe TwitterController do
  render_views

  it "should not fail when login" do
    get :login
    response.should be_redirect
  end

  it "should clear session when logout" do
    login nil
    get :logout
    session[:current_user_id].should be_nil
  end

end