class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!
  
  def index
    # ログイン済みの場合
    if user_signed_in?
      # ユーザーの質問数を確認
      checklist_count = current_user.checklists.count
      
      # SNSからの遷移（fromパラメータあり）かつ質問が5問以上ある場合
      if params[:from].present? && checklist_count >= 5
        # 自動開始フラグを付けてチェックリスト画面へ
        redirect_to checklists_path(auto_start: true, from: params[:from])
      else
        # 通常のチェックリスト画面へ
        redirect_to checklists_path
      end
    end
    # 未ログインの場合はWelcome画面を表示（何もしない）
  end
end