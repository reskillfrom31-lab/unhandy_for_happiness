class ApplicationController < ActionController::Base
  protected

  def after_sign_up_path_for(resource)
    checklists_path
  end
end
