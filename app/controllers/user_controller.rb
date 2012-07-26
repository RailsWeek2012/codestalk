class UserController < ApplicationController

  before_filter :require_login!

  def edit
    @user = User.find(params[:id])
  end

  def show
    @user = User.all
  end

  private

  def require_login!
    unless user_signed_in?
      redirect_to login_path,
                  alert: "Bitte melden Sie sich zuerst an."
    end
  end
end
