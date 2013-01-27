class DeleteReason
  include MongoMapper::Document

  key :email, String, :required => true
  key :reason, String, :required => true
  key :account_age_in_days, Float, :required => true
  key :account_created, Time, :required => true

  timestamps!
end


class MmUser
  include MongoMapper::Document

  validates_presence_of :email
end


class Seedling < Sinatra::Base
  set :sinatra_authentication_view_path, Pathname(__FILE__).dirname.expand_path + 'views/'

  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader
  end

  get '/' do
    @users = User.all
    @page_title = 'Home'
    haml :index
  end

  get '/login' do
    haml :login
  end

  post '/login' do
    if user = User.authenticate(params[:email], params[:password])
      session[:user] = user.id

      if session[:return_to]
        redirect_url = session[:return_to]
        session[:return_to] = false
        redirect redirect_url
      else
        redirect '/'
      end
    else
      flash[:error] = 'Wrong Email or Password'
      @email = params[:email]
      haml :login
    end
  end

  get '/forgot_password' do
    @page_title = "Forgot Password"
    haml :forgot_password
  end

  def send_email(to, subject, body)
      Pony.mail(:to => to,
                :subject => "[#{settings.project_name}] #{subject}",
                :body => body)
  end

  post '/forgot_password' do
    user = User.get(:email => params['email'])
    if user.nil?
      flash[:error] = "'#{h(params[:email])}' does not have an account here."
      redirect '/forgot_password'
    else
      secret = User.random_string(20)
      user.set(:secret => secret)
      send_email(user.email,
                 "Password Reset",
                 "You may reset your password here: http://#{request.host}/reset_password/#{secret}")

      @page_title = "Login"
      flash[:notice] = "Check your email! Instructions have been sent to #{user.email}"
      redirect '/'
    end
  end

  get '/reset_password/:secret' do
    if not User.get(:secret => params[:secret])
      flash[:error] = "Recovery code '#{h(params[:secret])}' has expired or does not exist"
      redirect '/'
    else
      @page_title = "Reset Password"
      haml :reset_password
    end
  end

  post '/reset_password' do
    user = User.get(:secret => params[:secret])
    if user.nil?
      flash[:error] = "Recovery code '#{h(params[:secret])}' has expired or does not exist"
      redirect '/'
    end

    password = params[:password]
    confirmation = params[:confirmation]

    if password.empty?
      flash[:error] = "Password may not be blank"
      redirect back
    elsif password != confirmation
      flash[:error] = "Password does not match confirmation"
      redirect back
    else
      flash[:notice] = "Password has now been changed."
      user.set(:hashed_password => User.encrypt(password, user.salt))
      session[:user] = user.id
      user.set(:secret => nil)
      redirect '/'
    end
  end

  get '/signup' do
    if logged_in?
      redirect '/'
    end

    haml :signup
  end

  post '/signup' do
    user_params = params[:user]

    if not params.has_key?('tos')
      @email = user_params[:email]
      flash[:error] = 'You must accept the Terms and Conditions'
      return haml :signup
    end

    @user = User.set(user_params)

    if @user.valid && @user.id
      session[:user] = @user.id
      redirect '/'
    else
      @email = user_params[:email]
      flash[:error] =  "#{@user.errors}."
      haml :signup
    end
  end

  get '/delete_account' do
    login_required
    @page_title = "Delete Account"
    haml :delete_account
  end

  post '/delete_account' do
    login_required

    if not User.authenticate(current_user.email, params[:password])
      @reason = params[:reason]
      flash[:error] = "Incorrect Password"
      redirect '/delete_account'
    end

    DeleteReason.create(:email => current_user.email,
                        :reason => params[:reason],
                        :account_created => current_user.created_at,
                        :account_age_in_days => ((Time.now - current_user.created_at) / 60 / 60 / 24).round(3))

    current_user.destroy
    session[:user] = nil
    redirect '/'
  end

  get '/settings' do
    login_required
    @user = current_user
    haml :settings
  end

  post '/settings' do
    login_required

    user_attributes = params[:user]

    password = params[:old_password]
    salt = current_user.salt

    user_attributes = params[:user]

    if user_attributes[:password] == ""
      user_attributes.delete("password")
      user_attributes.delete("password_confirmation")
      user_attributes[:password] = params[:old_password]
    end

    user = current_user

    if not User.authenticate(user.email, password)
      flash[:error] = "'Current password' was incorrect"
    elsif user.update(user_attributes)
      flash[:notice] = "Settings updated."
    else
      flash[:error] = user.errors
    end

    haml :settings
  end

  # Kept at the bottom so we can overwrite default routes
  register Sinatra::SinatraAuthentication

  helpers do
    def h(text)
      Rack::Utils.escape_html(text)
    end
  end
end
