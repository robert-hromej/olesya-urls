require 'test_helper'

class LinkControllerTest < ActionController::TestCase
  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get list" do
    get :list
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

  test "should get vote" do
    get :vote
    assert_response :success
  end

  test "should get comment" do
    get :comment
    assert_response :success
  end

  test "should get shorten" do
    get :shorten
    assert_response :success
  end

end
