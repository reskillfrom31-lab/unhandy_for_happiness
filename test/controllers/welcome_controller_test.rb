require "test_helper"

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  # テスト: 未ログイン状態でウェルカムページにアクセスできることを確認
  test "should get index without authentication" do
    get root_path
    assert_response :success
    assert_match /Unhandy for Happiness/, response.body
    assert_match /新規登録/, response.body
    assert_match /ログイン/, response.body
    assert_match /事前準備について確認する/, response.body
  end

  # テスト: ログイン済みユーザーがroot_pathにアクセスするとchecklists_pathにリダイレクトされることを確認
  test "should redirect to checklists when authenticated" do
    user = users(:one)
    sign_in user
    get root_path
    assert_redirected_to checklists_path
  end

# テスト: ログイン済み + 質問5個以上 + SNSからのアクセスでauto_start付きでリダイレクトされることを確認
test "should redirect to checklists with auto_start when from SNS" do
  user = users(:one)
  sign_in user
  
  # 質問が5個以上になるように追加
  current_count = user.checklists.count
  if current_count < 5
    (5 - current_count).times do |i|
      Checklist.create!(
        content: "テスト質問#{i + 1}",
        question_type: "free_text",
        user: user
      )
    end
  end
  
  assert user.checklists.count >= 5, "ユーザーの質問が5個未満です"
  
  get root_path, params: { from: 'youtube' }
  assert_redirected_to checklists_path(auto_start: true, from: 'youtube')
end

  # テスト: ログイン済みでも質問が5個未満の場合は通常のリダイレクト
  test "should redirect to checklists without auto_start when less than 5 questions" do
    user = users(:one)
    sign_in user
    
    # 質問を5個未満にする
    user.checklists.where('id > ?', user.checklists.limit(4).pluck(:id).max).destroy_all
    assert user.checklists.count < 5, "質問が5個以上あります"
    
    get root_path, params: { from: 'youtube' }
    assert_redirected_to checklists_path
  end

  # テスト: 未ログイン時にナビバーに「新規登録」と「ログイン」ボタンが表示されることを確認
  test "should display navbar with sign up and login buttons when not authenticated" do
    get root_path
    assert_response :success
    assert_match /新規登録/, response.body
    assert_match /ログイン/, response.body
    assert_match /navbar/, response.body
  end
end