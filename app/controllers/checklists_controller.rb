class ChecklistsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_checklist, only: %i[edit update destroy]
  
  # チェックリスト実行画面（質問に答える）
  def index
    @checklists = current_user.checklists.order(:display_order, created_at: :asc)
  end

  # 質問管理画面（追加・編集・削除）
  def manage
    @checklists = current_user.checklists.order(:display_order, created_at: :asc)
    @checklist = current_user.checklists.new
    @checklist.question_type ||= "free_text"
  end

  def new
    @checklist = current_user.checklists.new
    @checklist.question_type ||= "free_text"
  end
  
  def create
    @checklist = current_user.checklists.new(checklist_params)
    if @checklist.save
      redirect_to manage_checklists_path, notice: '質問が追加されました。'
    else
      render :new, status: :unprocessable_entity  # ← manage から new に変更
    end
  end

  def create_answer
    @checklist = current_user.checklists.find(params[:id])  # checklist_id → id に変更
    @answer = current_user.answers.new(
      checklist: @checklist,
      content: params[:content]  # JSONリクエストなので、このままでOK（Railsが自動的にパースする）
    )
    
    if @answer.save
      # 全ての質問に回答したかどうかを確認
      all_answered = all_questions_answered?
      render json: { 
        success: true, 
        message: '回答を保存しました',
        all_answered: all_answered
      }
    else
      render json: { success: false, errors: @answer.errors.full_messages }
    end
  end

  def check_all_answered
    all_answered = all_questions_answered?
    render json: { all_answered: all_answered }
  end
  # 公開質問一覧
  def public_index
    @public_checklists = Checklist.where(is_public: true)
                                  .includes(:user)
                                  .order(created_at: :desc)
                                  .limit(100)
  end

  def edit
  end

  def update
    if @checklist.update(checklist_params)
      redirect_to manage_checklists_path, notice: '質問が更新されました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user.checklists.count <= 5
      redirect_to manage_checklists_path, alert: '質問は最低5個必要です。'
    else
      @checklist.destroy
      redirect_to manage_checklists_path, notice: '質問が削除されました。', status: :see_other
    end
  end

  private

  def set_checklist
    @checklist = current_user.checklists.find(params[:id])
  end

  def checklist_params
    params.require(:checklist).permit(:content, :question_type, :is_public)
  end

  def all_questions_answered?
    # ユーザーの全てのチェックリストを取得
    all_checklists = current_user.checklists
    return false if all_checklists.empty?
    
    # 各チェックリストに対して、最新の回答が存在するか確認
    all_checklists.all? do |checklist|
      current_user.answers.where(checklist: checklist).exists?
    end
  end
end