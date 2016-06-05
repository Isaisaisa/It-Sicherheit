class UsersController < ApplicationController
  PKI_DIR = "/opt/pki"
  CERT_DIR = "#{PKI_DIR}/certs"
  CONF_DIR = "#{PKI_DIR}/etc"
  CA_DIR = "#{PKI_DIR}/ca"
  before_action :logged_in_user, only: [:new, :create, :index, :edit, :update, :destroy, :certificate, :certificatepassword, :createcertificate]
  before_action :correct_user, only: [:certificate, :certificatepassword, :createcertificate]
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

  def certificate
    if File.file?("#{CERT_DIR}/#{current_user.id.to_s}.p12")
      send_file("#{CERT_DIR}/#{current_user.id.to_s}.p12", filename: "#{current_user.id.to_s}.p12", type: "application/x-pkcs12")
    else
      redirect_to certificatepassword_user_path
    end
  end

  def certificatepassword

  end

  def createcertificate
    if @user.authenticate(params[:user][:password])
      create_p12 params[:user][:password]
      send_file("#{CERT_DIR}/#{current_user.id.to_s}.p12", filename: "#{current_user.id.to_s}.p12", type: "application/x-pkcs12")
      redirect_to @user
    else
      flash[:danger] = "Wrong Password"
      redirect_to certificatepassword_user_path
    end
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



  def create_p12(password)
    subj = "/C=DE/O=HAW-HAMBURG/OU=INFORMATIK/CN=#{current_user.id.to_s}"
    dir_name  = "#{CERT_DIR}"
    Dir.mkdir(dir_name) unless File.directory?(dir_name)
    create_cert(subj, password)
    sign_cert password
    generate_p12 password
  end

  def create_cert(subj,password)
    Dir.chdir(PKI_DIR) do
      system("openssl req -new -config #{CONF_DIR}/client.conf -out #{CERT_DIR}/#{current_user.id.to_s}.csr -keyout #{CERT_DIR}/#{current_user.id.to_s}.key -subj \"#{subj}\" -passout pass:#{password} -batch")
    end
  end

  def sign_cert(password)
    Dir.chdir(PKI_DIR) do
      system("openssl ca -config #{CONF_DIR}/ssl-ca.conf -in #{CERT_DIR}/#{current_user.id.to_s}.csr -out #{CERT_DIR}/#{current_user.id.to_s}.crt -policy extern_pol -extensions client_ext -passin pass:password -batch")
    end
  end

  def generate_p12(password)
    Dir.chdir(PKI_DIR) do
      system("openssl pkcs12 -export -clcerts -in #{CERT_DIR}/#{current_user.id.to_s}.crt -certfile #{CA_DIR}/ssl-ca-chain.pem -inkey #{CERT_DIR}/#{current_user.id.to_s}.key -out #{CERT_DIR}/#{current_user.id.to_s}.p12 -name #{current_user.id.to_s} -passout pass:#{password} -passin pass:#{password}")
    end
  end

end
