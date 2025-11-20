require "test_helper"

class SetupControllerTest < ActionDispatch::IntegrationTest
  test "should get index without authentication" do
    get root_path
    assert_response :success
  end

  test "should get index when authenticated" do
    user = users(:one)
    sign_in user
    get root_path
    assert_response :success
  end

  test "should get index via setup_index_url" do
    get setup_index_url
    assert_response :success
  end

  test "should display setup guide content" do
    get root_path
    assert_response :success
    assert_match /事前準備ガイド/, response.body
    assert_match /Googleアカウント/, response.body
    assert_match /unhandy_redirector/, response.body
    assert_match /アカウントの作成/, response.body
  end
end
