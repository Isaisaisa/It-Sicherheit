class UsersController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :index, :edit, :update, :destroy]
  before_action :correct_user_or_admin,   only: [:edit, :update]
  before_action :admin_user,     only: [:new, :create, :index, :destroy]


  def index
    @users = User.all
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def create
    @user = User.new(user_params)
    @user.email_token_time=DateTime.now
    if @user.save
      #log_in @user
      flash[:success] = "Successfully created User: " + @user.email
      flash[:warning] = UserMailer.registration_confirmation(@user).to_s
      redirect_to @user
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
    redirect_to users_url
  end

  def confirm_email
    user = User.find_by_confirm_token(params[:id])
    if user
      if (user.email_token_time + 39.minutes) > DateTime.now
        user.email_activate
        flash[:success] = "Welcome to the Sample App! Your email has been confirmed.
        Please sign in to continue."
        redirect_to login_url
      else
        flash[:danger] = "Sorry. Tokentime expired"
        redirect_to root_url
      end
    else
      flash[:danger] = "Sorry. User does not exist"
      redirect_to root_url
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
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
    redirect_to(root_url) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end

  def correct_user_or_admin
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user.admin? or current_user?(@user)
  end

end
