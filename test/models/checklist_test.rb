require "test_helper"

class ChecklistTest < ActiveSupport::TestCase
  def setup
    @checklist = checklists(:one)
  end

  test "should be valid" do
    assert @checklist.valid?
  end

  test "should require content" do
    @checklist.content = nil
    assert_not @checklist.valid?
    assert_includes @checklist.errors[:content], "can't be blank"
  end

  test "should require content to be present" do
    @checklist.content = ""
    assert_not @checklist.valid?
    assert_includes @checklist.errors[:content], "can't be blank"
  end

  test "should require question_type" do
    @checklist.question_type = nil
    assert_not @checklist.valid?
    assert_includes @checklist.errors[:question_type], "can't be blank"
  end

  test "should belong to user" do
    assert_respond_to @checklist, :user
    assert_equal users(:one), @checklist.user
  end

  test "should have many answers" do
    assert_respond_to @checklist, :answers
    answer = Answer.new(content: "Test answer", user: @checklist.user, checklist: @checklist)
    assert answer.save
    assert_includes @checklist.answers, answer
  end

  test "should destroy associated answers when checklist is destroyed" do
    answer = answers(:one)
    checklist = answer.checklist
    answer_count = checklist.answers.count
    assert answer_count > 0
    
    checklist.destroy
    assert_equal 0, Answer.where(checklist_id: checklist.id).count
  end

  test "should accept valid question types" do
    valid_types = ["free_text", "yes_no", "numeric"]
    valid_types.each do |type|
      @checklist.question_type = type
      assert @checklist.valid?, "#{type} should be a valid question_type"
    end
  end
end
