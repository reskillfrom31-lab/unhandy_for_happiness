class SetupController < ApplicationController
  # 未ログインでもアクセス可能に
  skip_before_action :authenticate_user!
  
  def index
  end
end