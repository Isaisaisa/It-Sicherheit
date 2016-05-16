class UsersController < ApplicationController
  
  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "Welcome to the IT-Sicherheit Secure Login!"
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

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end
end
