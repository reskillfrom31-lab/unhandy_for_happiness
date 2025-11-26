require "test_helper"

class ChecklistsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @checklist = checklists(:one)
    sign_in @user
  end

  # テスト: ログイン状態でチェックリスト一覧ページにアクセスできることを確認
  test "should get index when authenticated" do
    get checklists_path
    assert_response :success
  end

  # テスト: 未ログイン状態でチェックリストページにアクセスするとログインページにリダイレクトされることを確認
  test "should redirect to login when not authenticated" do
    sign_out @user
    get checklists_path
    assert_redirected_to new_user_session_path
  end

  # テスト: 新しいチェックリストを作成できることを確認
  test "should create checklist" do
    assert_difference("Checklist.count", 1) do
      post checklists_path, params: {
        checklist: {
          content: "新しい質問",
          question_type: "free_text"
        }
      }
    end
    assert_redirected_to checklists_path
  end

  # テスト: 無効なパラメータではチェックリストが作成されないことを確認
  test "should not create checklist with invalid params" do
    assert_no_difference("Checklist.count") do
      post checklists_path, params: {
        checklist: {
          content: "",
          question_type: "free_text"
        }
      }
    end
  end

  # テスト: チェックリスト編集ページにアクセスできることを確認
  test "should get edit" do
    get edit_checklist_path(@checklist)
    assert_response :success
  end

  # テスト: チェックリストを更新できることを確認
  test "should update checklist" do
    patch checklist_path(@checklist), params: {
      checklist: {
        content: "更新された質問",
        question_type: "yes_no"
      }
    }
    assert_redirected_to checklists_path
    @checklist.reload
    assert_equal "更新された質問", @checklist.content
    assert_equal "yes_no", @checklist.question_type
  end

  # テスト: 無効なパラメータではチェックリストが更新されないことを確認
  test "should not update checklist with invalid params" do
    original_content = @checklist.content
    patch checklist_path(@checklist), params: {
      checklist: {
        content: "",
        question_type: "free_text"
      }
    }
    @checklist.reload
    assert_equal original_content, @checklist.content
  end

  # テスト: チェックリストが5個以下の場合は削除できないことを確認
  test "should not destroy checklist when count is 5 or less" do
    # ユーザーのチェックリストが5個以下の場合、削除できない
    user_checklists_count = @user.checklists.count
    if user_checklists_count <= 5
      assert_no_difference("Checklist.count") do
        delete checklist_path(@checklist)
      end
      assert_redirected_to checklists_path
      assert_equal "質問は最低5個必要です。", flash[:alert]
    end
  end

  # テスト: チェックリストが6個以上の場合は削除できることを確認
  test "should destroy checklist when count is more than 5" do
    # テスト用に6個以上のチェックリストを作成
    user_checklists_count = @user.checklists.count
    if user_checklists_count <= 5
      # 6個目を作成
      Checklist.create!(
        content: "追加の質問1",
        question_type: "free_text",
        user: @user
      )
    end

    user_checklists_count = @user.checklists.count
    if user_checklists_count > 5
      checklist_to_delete = @user.checklists.last
      assert_difference("Checklist.count", -1) do
        delete checklist_path(checklist_to_delete)
      end
      assert_redirected_to checklists_path
      assert_equal "質問が削除されました。", flash[:notice]
    end
  end

  # テスト: 回答を作成できることを確認
  test "should create answer" do
    assert_difference("Answer.count", 1) do
      post create_answer_checklist_path(@checklist), params: {
        content: "テスト回答"
      }, as: :json
    end
    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response["success"]
  end

  # テスト: 空の内容では回答が作成されないことを確認
  test "should not create answer with empty content" do
    assert_no_difference("Answer.count") do
      post create_answer_checklist_path(@checklist), params: {
        content: ""
      }, as: :json
    end
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_not json_response["success"]
  end

  # テスト: 全ての質問に回答済みかどうかを確認するAPIが動作することを確認
  test "should check all answered" do
    get check_all_answered_checklists_path
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_includes json_response.keys, "all_answered"
  end

  # テスト: 他のユーザーのチェックリストにはアクセスできないことを確認
  test "should only access own checklists" do
    other_user = users(:two)
    other_checklist = checklists(:three)
    
    get edit_checklist_path(other_checklist)
    assert_response :not_found
  end

  # テスト: ログイン時にナビバーに「ログアウト」ボタンが表示され、「新規登録」「ログイン」ボタンが非表示であることを確認
  test "should display navbar with logout button when authenticated" do
    get checklists_path
    assert_response :success
    assert_match /ログアウト/, response.body
    assert_match /navbar/, response.body
    assert_no_match /新規登録/, response.body
    assert_no_match /ログイン/, response.body
  end
end
