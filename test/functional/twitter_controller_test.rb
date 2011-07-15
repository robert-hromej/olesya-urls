require 'test_helper'

class TwitterControllerTest < ActionController::TestCase
  test "should get login" do
    get :login
    assert_response :success
  end

  test "should get twitt" do
    get :tweet
    assert_response :success
  end

  test "should get after_login" do
    get :after_login
    assert_response :success
  end

end
