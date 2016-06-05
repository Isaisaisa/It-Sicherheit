class SessionsController < ApplicationController

  def new
  end

  def createcert
    if request.env['SSL_CLIENT_VERIFY'] == "SUCCESS"
      userid = -1
      request.env['SSL_CLIENT_S_DN'].split(',').each{ |param| param.start_with?("CN") ? userid = param.split('=')[1] : nil}
      user = User.find(userid)
      if user
        loginuser(user)
      else
        flash[:danger] = "User not found"
        redirect_to root_path
      end
    else
      flash[:danger] = "Invalid Certificate"
      redirect_to root_path
    end
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      loginuser(user)
    else
      flash[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path
  end

  private

  def loginuser(user)
    puts "loginuser user: " + user.to_s
    if user.activated?
      log_in user
      if params[:session]
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      end
      redirect_back_or user
    else
      message  = "Account not activated. "
      message += "Check your email for the activation link."
      flash[:warning] = message
      redirect_to root_path
    end
  end
end
