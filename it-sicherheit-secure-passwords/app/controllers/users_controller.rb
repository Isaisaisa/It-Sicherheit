class UsersController < ApplicationController
  PKI_DIR = "/opt/pki"
  CERT_DIR = "#{PKI_DIR}/certs"
  CONF_DIR = "#{PKI_DIR}/etc"
  CA_DIR = "#{PKI_DIR}/ca"
  before_action :logged_in_user, only: [:new, :create, :index, :edit, :update, :destroy, :certificate]
  before_action :correct_user, only: [:certificate]
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
    create_p12 unless File.file?("#{CERT_DIR}/#{current_user.email}.p12")
    send_file("#{CERT_DIR}/#{current_user.email}.p12", filename: "#{current_user.email}.p12", type: "application/x-pkcs12")
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



  def create_p12
    subj = "/C=DE/O=HAW-HAMBURG/OU=INFORMATIK/CN=#{current_user.email})/emailAddress=#{current_user.email}"
    dir_name  = "#{CERT_DIR}"
    Dir.mkdir(dir_name) unless File.directory?(dir_name)
    create_cert(subj)
    sign_cert
    generate_p12
  end

  def create_cert(subj)
    Dir.chdir(PKI_DIR) do
      system("openssl req -new -config #{CONF_DIR}/client.conf -out #{CERT_DIR}/#{current_user.email}.csr -keyout #{CERT_DIR}/#{current_user.email}.key -subj '#{subj}' -passout pass:password -batch")
    end
  end

  def sign_cert
    Dir.chdir(PKI_DIR) do
      system("openssl ca -config #{CONF_DIR}/ssl-ca.conf -in #{CERT_DIR}/#{current_user.email}.csr -out #{CERT_DIR}/#{current_user.email}.crt -policy extern_pol -extensions client_ext -passin pass:password -batch")
    end
  end

  def generate_p12
    Dir.chdir(PKI_DIR) do
      system("openssl pkcs12 -export -clcerts -in #{CERT_DIR}/#{current_user.email}.crt -certfile #{CA_DIR}/ssl-ca-chain.pem -inkey #{CERT_DIR}/#{current_user.email}.key -out #{CERT_DIR}/#{current_user.email}.p12 -name #{current_user.email} -passout pass:password")
    end
  end

end
