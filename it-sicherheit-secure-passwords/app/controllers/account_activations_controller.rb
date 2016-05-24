class AccountActivationsController < ApplicationController
  before_action :get_user,   only: [:edit]
  before_action :valid_user, only: [:edit]
  before_action :check_expiration, only: [:edit]

  def edit
    user = @user
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_path
    end
  end

  private


  def get_user
    @user = User.find_by(email: params[:email])
  end

  # Confirms a valid user.
  def valid_user
    unless (@user && !@user.activated? &&
        @user.authenticated?(:activation, params[:id]))
      flash[:danger] = "Invalid credentials"
      redirect_to root_path
    end
  end

  def check_expiration
    if @user.activation_expired?
      flash[:danger] = "Activation has expired."
      redirect_to root_path
    end
  end

end
