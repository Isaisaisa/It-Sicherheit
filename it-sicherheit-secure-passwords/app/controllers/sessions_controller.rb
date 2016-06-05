class SessionsController < ApplicationController
  def new
    flash[:success] = request.env['SSL_CLIENT_S_DN']
    flash[:warning] = request.env['SSL_CLIENT_VERIFY']
	flash[:danger] = request.env['SSL-Subject']
	
  end

  def createcert
    if request.env['SSL_CLIENT_VERIFY'] == "SUCCESS"
      puts "userid: " + request.env['SSL_CLIENT_S_DN'].to_a.select{| name, _, _| name == 'CN'}.first[1]
      user = User.find_by(id: request.env['SSL_CLIENT_S_DN'].to_a.select{| name, _, _| name == 'CN'}.first[1])
      loginuser(user)
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
    if user.activated?
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_back_or user
    else
      message  = "Account not activated. "
      message += "Check your email for the activation link."
      flash[:warning] = message
      redirect_to root_path
    end
  end
end
