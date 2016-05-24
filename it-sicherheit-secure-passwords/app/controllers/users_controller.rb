class UsersController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :index, :edit, :update, :destroy]
  before_action :correct_user_or_admin,   only: [:edit, :update]
  before_action :admin_user,     only: [:new, :create, :index, :destroy]
  after_filter :update_flash_warning

  def index
    @users = User.all
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    # puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" + params[:user][:future_send_email].to_s
    # if(@user.email == params[:future_send_email])
    #   params[:future_email] = nil
    # else
    #   params[:future_email] = params[:future_send_email]
    # end

    if @user.update_attributes(user_update_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_path
    else
      render 'new'
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  def user_update_params
    params.require(:user).permit(:name, :password, :future_send_email,
                                 :password_confirmation)
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end

  def correct_user_or_admin
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user.admin? or current_user?(@user)
  end

  private

  def update_flash_warning
    if !@user.nil? && !@user.flash_warning.blank?
      flash[:warning] = @user.flash_warning
    end
  end

end
