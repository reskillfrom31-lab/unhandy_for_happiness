require "test_helper"

class SetupControllerTest < ActionDispatch::IntegrationTest
  # テスト: 未ログイン状態でもセットアップページにアクセスできることを確認
  test "should get index without authentication" do
    get root_path
    assert_response :success
  end

  # テスト: ログイン状態でもセットアップページにアクセスできることを確認
  test "should get index when authenticated" do
    user = users(:one)
    sign_in user
    get root_path
    assert_response :success
  end

  # テスト: setup_index_urlでセットアップページにアクセスできることを確認
  test "should get index via setup_index_url" do
    get setup_index_url
    assert_response :success
  end

  # テスト: セットアップガイドの内容が表示されることを確認
  test "should display setup guide content" do
    get root_path
    assert_response :success
    assert_match /事前準備ガイド/, response.body
    assert_match /Googleアカウント/, response.body
    assert_match /unhandy_redirector/, response.body
    assert_match /アカウントの作成/, response.body
  end

  # テスト: 未ログイン時にナビバーに「新規登録」と「ログイン」ボタンが表示されることを確認
  test "should display navbar with sign up and login buttons when not authenticated" do
    get root_path
    assert_response :success
    assert_match /新規登録/, response.body
    assert_match /ログイン/, response.body
    assert_match /navbar/, response.body
  end

  # テスト: ログイン時にナビバーに「ログアウト」ボタンが表示され、「新規登録」ボタンが非表示であることを確認
  test "should display navbar with logout button when authenticated" do
    user = users(:one)
    sign_in user
    get root_path
    assert_response :success
    assert_match /ログアウト/, response.body
    assert_match /navbar/, response.body
    assert_no_match /新規登録/, response.body
    # 「ログイン」ボタンやリンクが表示されていないことを確認（説明文の「ログイン」は除外）
    assert_no_match /<a[^>]*>.*ログイン.*<\/a>/, response.body
    assert_no_match /action-button.*ログイン/, response.body
  end
end
