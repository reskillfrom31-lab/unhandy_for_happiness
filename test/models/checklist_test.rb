require "test_helper"

class ChecklistTest < ActiveSupport::TestCase
  def setup
    @checklist = checklists(:one)
  end

  # テスト: fixtureのチェックリストが有効であることを確認
  test "should be valid" do
    assert @checklist.valid?
  end

  # テスト: contentがnilの場合は無効であることを確認
  test "should require content" do
    @checklist.content = nil
    assert_not @checklist.valid?
    assert_includes @checklist.errors[:content], "can't be blank"
  end

  # テスト: contentが空文字の場合は無効であることを確認
  test "should require content to be present" do
    @checklist.content = ""
    assert_not @checklist.valid?
    assert_includes @checklist.errors[:content], "can't be blank"
  end

  # テスト: question_typeが必須であることを確認
  test "should require question_type" do
    @checklist.question_type = nil
    assert_not @checklist.valid?
    assert_includes @checklist.errors[:question_type], "can't be blank"
  end

  # テスト: チェックリストがユーザーに属していることを確認
  test "should belong to user" do
    assert_respond_to @checklist, :user
    assert_equal users(:one), @checklist.user
  end

  # テスト: チェックリストが複数の回答を持てることを確認
  test "should have many answers" do
    assert_respond_to @checklist, :answers
    answer = Answer.new(content: "Test answer", user: @checklist.user, checklist: @checklist)
    assert answer.save
    assert_includes @checklist.answers, answer
  end

  # テスト: チェックリスト削除時に関連する回答も削除されることを確認
  test "should destroy associated answers when checklist is destroyed" do
    answer = answers(:one)
    checklist = answer.checklist
    answer_count = checklist.answers.count
    assert answer_count > 0
    
    checklist.destroy
    assert_equal 0, Answer.where(checklist_id: checklist.id).count
  end

  # テスト: 有効なquestion_type（free_text, yes_no, numeric）が受け入れられることを確認
  test "should accept valid question types" do
    valid_types = ["free_text", "yes_no", "numeric"]
    valid_types.each do |type|
      @checklist.question_type = type
      assert @checklist.valid?, "#{type} should be a valid question_type"
    end
  end
end
