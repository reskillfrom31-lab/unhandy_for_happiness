require "test_helper"

class AnswerTest < ActiveSupport::TestCase
  def setup
    @answer = answers(:one)
  end

  # テスト: fixtureの回答が有効であることを確認
  test "should be valid" do
    assert @answer.valid?
  end

  # テスト: contentがnilの場合は無効であることを確認
  test "should require content" do
    @answer.content = nil
    assert_not @answer.valid?
    assert_includes @answer.errors[:content], "can't be blank"
  end

  # テスト: contentが空文字の場合は無効であることを確認
  test "should require content to be present" do
    @answer.content = ""
    assert_not @answer.valid?
    assert_includes @answer.errors[:content], "can't be blank"
  end

  # テスト: 回答がユーザーに属していることを確認
  test "should belong to user" do
    assert_respond_to @answer, :user
    assert_equal users(:one), @answer.user
  end

  # テスト: 回答がチェックリストに属していることを確認
  test "should belong to checklist" do
    assert_respond_to @answer, :checklist
    assert_equal checklists(:one), @answer.checklist
  end

  # テスト: 回答が正しいユーザーとチェックリストに関連付けられることを確認
  test "should be associated with correct user and checklist" do
    user = users(:one)
    checklist = checklists(:one)
    answer = Answer.new(content: "Test answer", user: user, checklist: checklist)
    
    assert answer.save
    assert_equal user, answer.user
    assert_equal checklist, answer.checklist
  end
end
