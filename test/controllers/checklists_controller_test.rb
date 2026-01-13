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

  # テスト: 未ログイン状態でチェックリストページにアクセスするとウェルカムページにリダイレクトされることを確認
  test "should redirect to welcome when not authenticated" do
    sign_out @user
    get checklists_path
    assert_redirected_to new_user_session_path
  end

  # テスト: 質問管理ページにアクセスできることを確認
  test "should get manage when authenticated" do
    get manage_checklists_path
    assert_response :success
    assert_match /質問の管理/, response.body
    assert_match /新しい質問を追加/, response.body
  end

  # テスト: 未ログイン状態で質問管理ページにアクセスするとログインページにリダイレクトされることを確認
  test "should redirect to login when accessing manage without authentication" do
    sign_out @user
    get manage_checklists_path
    assert_redirected_to new_user_session_path
  end

  # テスト: 質問追加ページにアクセスできることを確認
  test "should get new when authenticated" do
    get new_checklist_path
    assert_response :success
    assert_match /新しい質問を追加/, response.body
  end

  # テスト: 未ログイン状態で質問追加ページにアクセスするとログインページにリダイレクトされることを確認
  test "should redirect to login when accessing new without authentication" do
    sign_out @user
    get new_checklist_path
    assert_redirected_to new_user_session_path
  end

  # テスト: 新しいチェックリストを作成できることを確認
  test "should create checklist" do
    assert_difference("Checklist.count", 1) do
      post checklists_path, params: {
        checklist: {
          content: "新しい質問",
          question_type: "free_text",
          is_public: false
        }
      }
    end
    assert_redirected_to manage_checklists_path
    assert_equal "質問が追加されました。", flash[:notice]
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
    assert_response :unprocessable_content  # newテンプレートがレンダリングされる
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
    assert_redirected_to manage_checklists_path
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
    user_checklists_count = @user.checklists.count
    if user_checklists_count <= 5
      assert_no_difference("Checklist.count") do
        delete checklist_path(@checklist)
      end
      assert_redirected_to manage_checklists_path
      assert_equal "質問は最低5個必要です。", flash[:alert]
    end
  end

  # テスト: チェックリストが6個以上の場合は削除できることを確認
  test "should destroy checklist when count is more than 5" do
    user_checklists_count = @user.checklists.count
    if user_checklists_count <= 5
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
      assert_redirected_to manage_checklists_path
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

  # テスト: 公開質問一覧ページにアクセスできることを確認
  test "should get public_index when authenticated" do
    get public_index_checklists_path
    assert_response :success
    assert_match /みんなの質問/, response.body
  end

  # テスト: 他のユーザーのチェックリストにはアクセスできないことを確認
  test "should only access own checklists" do
    other_user = users(:two)
    other_checklist = checklists(:three)
    
    get edit_checklist_path(other_checklist)
    assert_response :not_found
  end

  # テスト: チェックリスト実行画面では「質問を管理する」ボタンのみ表示されることを確認
  test "should display only manage button in index page when authenticated" do
    get checklists_path
    assert_response :success
    assert_match /質問を管理する/, response.body
    assert_no_match /ログアウト/, response.body
    assert_no_match /新規登録/, response.body
    assert_no_match /ログイン/, response.body
  end

  # テスト: 質問管理画面では「チェックリストに戻る」と「ログアウト」ボタンが表示されることを確認
  test "should display back and logout buttons in manage page when authenticated" do
    get manage_checklists_path
    assert_response :success
    assert_match /チェックリストに戻る/, response.body
    assert_match /ログアウト/, response.body
  end

  # テスト: 許可されていないパラメータは無視されることを確認（マスアサインメント攻撃防止）
  test "should not allow mass assignment of user_id" do
    other_user = users(:two)
    
    post checklists_path, params: {
      checklist: {
        content: "新しい質問",
        question_type: "free_text",
        user_id: other_user.id  # 悪意のあるパラメータ
      }
    }
    
    # 作成されたチェックリストが現在のユーザーに紐づいていることを確認
    created_checklist = Checklist.last
    assert_equal @user.id, created_checklist.user_id
    assert_not_equal other_user.id, created_checklist.user_id
  end

  # テスト: display_orderを不正に操作できないことを確認
  test "should not allow mass assignment of display_order" do
    post checklists_path, params: {
      checklist: {
        content: "新しい質問",
        question_type: "free_text",
        display_order: 999  # 悪意のあるパラメータ
      }
    }
    
    # display_orderが不正に設定されていないことを確認
    created_checklist = Checklist.last
    assert_not_equal 999, created_checklist.display_order
  end

  # テスト: 他のユーザーのチェックリストを更新できないことを確認
  test "should not update other user's checklist" do
    other_user = users(:two)
    other_checklist = checklists(:three)
    
    assert_no_changes -> { other_checklist.reload.content } do
      patch checklist_path(other_checklist), params: {
        checklist: {
          content: "悪意のある変更"
        }
      }
    end
    
    assert_response :not_found
  end

  # テスト: 他のユーザーのチェックリストを削除できないことを確認
  test "should not destroy other user's checklist" do
    other_user = users(:two)
    other_checklist = checklists(:three)
    
    assert_no_difference("Checklist.count") do
      delete checklist_path(other_checklist)
    end
    
    assert_response :not_found
  end

  # テスト: 他のユーザーのチェックリストに回答できないことを確認
  test "should not create answer for other user's checklist" do
    other_user = users(:two)
    other_checklist = checklists(:three)
    
    assert_no_difference("Answer.count") do
      post create_answer_checklist_path(other_checklist), params: {
        content: "不正な回答"
      }, as: :json
    end
    
    assert_response :not_found
  end

  # テスト: 非公開の質問が公開一覧に表示されないことを確認
  test "should not display private checklists in public index" do
    # 非公開の質問を作成
    private_checklist = Checklist.create!(
      content: "非公開の質問",
      question_type: "free_text",
      is_public: false,
      user: @user
    )
    
    get public_index_checklists_path
    assert_response :success
    assert_no_match /非公開の質問/, response.body
  end

  # テスト: 公開質問一覧でユーザーのメールアドレスが表示されないことを確認
  test "should not display user email in public index" do
    # 公開の質問を作成
    public_checklist = Checklist.create!(
      content: "公開の質問",
      question_type: "free_text",
      is_public: true,
      user: @user
    )
    
    get public_index_checklists_path
    assert_response :success
    assert_no_match /#{@user.email}/, response.body
    assert_match /匿名ユーザー/, response.body
  end

  # テスト: 悪意のあるスクリプトがエスケープされることを確認
  test "should escape malicious scripts in checklist content" do
    malicious_content = "<script>alert('XSS')</script>"
    
    post checklists_path, params: {
      checklist: {
        content: malicious_content,
        question_type: "free_text",
        is_public: true
      }
    }
    
    created_checklist = Checklist.last
    assert_equal malicious_content, created_checklist.content  # DBには保存される
    
    # 公開画面でエスケープされているか確認
    get public_index_checklists_path
    assert_response :success
    assert_no_match /<script>alert\('XSS'\)<\/script>/, response.body  # 生のスクリプトは表示されない
    assert_match /&lt;script&gt;/, response.body  # エスケープされている
  end
  # テスト: ログアウト後は認証が必要になることを確認
  test "should require authentication after logout" do
    get checklists_path
    assert_response :success
    
    # ログアウト
    sign_out @user
    
    # 再度アクセスすると認証が必要
    get checklists_path
    assert_redirected_to new_user_session_path
  end

  # テスト: 他のユーザーでログインし直すと、前のユーザーのデータにアクセスできないことを確認
  test "should not access previous user data after switching users" do
    user_one = users(:one)
    user_two = users(:two)
    
    # user_one でログイン
    sign_in user_one
    get checklists_path
    assert_response :success
    
    # user_two に切り替え
    sign_out user_one
    sign_in user_two
    
    # user_one のチェックリストにアクセスできない
    user_one_checklist = user_one.checklists.first
    get edit_checklist_path(user_one_checklist)
    assert_response :not_found
  end

  # テスト: 異常に長い質問は保存できないことを確認
  test "should not save checklist with extremely long content" do
    checklist = Checklist.new(
      content: "a" * 10001,  # 10000文字以上
      question_type: "free_text",
      user: users(:one)
    )
    
    assert_not checklist.valid?
  end

  # テスト: SQLインジェクションの試行が無害化されることを確認
  test "should safely handle SQL injection attempts" do
    malicious_content = "'; DROP TABLE checklists; --"
    
    checklist = Checklist.create!(
      content: malicious_content,
      question_type: "free_text",
      user: users(:one)
    )
    
    # チェックリストが正常に保存される
    assert checklist.persisted?
    
    # 検索しても問題ない
    found = Checklist.where("content LIKE ?", "%#{malicious_content}%").first
    assert_equal checklist.id, found.id
    
    # テーブルが削除されていない
    assert Checklist.count > 0
  end
end