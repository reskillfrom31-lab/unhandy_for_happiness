class ChecklistsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_checklist, only: %i[edit update destroy]
  
  def index
    @checklists = current_user.checklists.order(created_at: :asc)
    @checklist = current_user.checklists.new
    @checklist.question_type ||= "free_text"  # デフォルト値を設定
  end

  def new
  end
  
  def create
    @checklist = current_user.checklists.new(checklist_params)
    if @checklist.save
      redirect_to checklists_path, notice: '質問が追加されました。'
    else
      @checklists = current_user.checklists.order(created_at: :asc)
      render :index, status: :unprocessable_entity
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

  def edit
  end

  def update
    if @checklist.update(checklist_params)
      redirect_to checklists_path, notice: '質問が更新されました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user.checklists.count <= 5
      redirect_to checklists_path, alert: '質問は最低5個必要です。'
    else
      @checklist.destroy
      redirect_to checklists_path, notice: '質問が削除されました。', status: :see_other
    end
  end

  private

  def set_checklist
    @checklist = current_user.checklists.find(params[:id])
  end

  def checklist_params
    params.require(:checklist).permit(:content, :question_type)
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