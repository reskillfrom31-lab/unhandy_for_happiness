require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "should require email" do
    @user.email = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "should require unique email" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email
    assert_not duplicate_user.valid?
  end

  test "should have many checklists" do
    assert_respond_to @user, :checklists
    checklist = Checklist.new(content: "Test question", question_type: "free_text", user: @user)
    assert checklist.save
    assert_includes @user.checklists, checklist
  end

  test "should destroy associated checklists when user is destroyed" do
    checklist = checklists(:one)
    user = checklist.user
    checklist_count = user.checklists.count
    assert checklist_count > 0
    
    user.destroy
    assert_equal 0, Checklist.where(user_id: user.id).count
  end

  test "should have many answers" do
    assert_respond_to @user, :answers
    answer = Answer.new(content: "Test answer", user: @user, checklist: checklists(:one))
    assert answer.save
    assert_includes @user.answers, answer
  end

  test "should destroy associated answers when user is destroyed" do
    answer = answers(:one)
    user = answer.user
    answer_count = user.answers.count
    assert answer_count > 0
    
    user.destroy
    assert_equal 0, Answer.where(user_id: user.id).count
  end
end
