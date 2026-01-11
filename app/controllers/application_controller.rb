class ApplicationController < ActionController::Base
  # 全てのアクションでログイン必須にする
  before_action :authenticate_user!
  
  protected

  # 新規登録後はチェックリスト画面へ
  def after_sign_up_path_for(resource)
    checklists_path
  end
  
  # ログイン後もチェックリスト画面へ
  def after_sign_in_path_for(resource)
    checklists_path
  end
  
  # 未ログイン時のリダイレクト先をウェルカム画面に設定
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end