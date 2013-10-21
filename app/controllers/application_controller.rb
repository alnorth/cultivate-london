class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    if current_user.nil?
      redirect_to new_user_session_path, :alert => exception.message
    elsif can? :manage, Batch
      redirect_to root_path, :alert => exception.message
    else
      redirect_to reports_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
