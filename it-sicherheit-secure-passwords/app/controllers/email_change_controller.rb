class EmailChangeController < ApplicationController
  before_action :get_user,   only: [:edit]
  before_action :valid_user, only: [:edit]
  before_action :check_expiration, only: [:edit]

  def edit
    user = @user
    if user && user.activated? && user.authenticated?(:email_change, params[:id])
      user.change_email
      log_in user
      flash[:success] = "Successfully changed Email"
      redirect_to user
    else
      flash[:danger] = "Invalid email change link"
      redirect_to root_path
    end
  end



  private


  def get_user
    @user = User.find_by(future_email: params[:email])
  end

  # Confirms a valid user.
  def valid_user
    unless (@user && @user.activated? &&
        @user.authenticated?(:email_change, params[:id]))
      flash[:danger] = "Invalid credentials"
      redirect_to root_path
    end
  end

  def check_expiration
    if @user.email_change_expired?
      flash[:danger] = "Activation has expired."
      redirect_to root_path
    end
  end

end
