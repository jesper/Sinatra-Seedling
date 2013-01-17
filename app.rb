require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'mongo_mapper'
require 'sinatra-authentication'
require 'haml'
require 'rack/csrf'

class Seedling < Sinatra::Base
  set :sinatra_authentication_view_path, Pathname(__FILE__).dirname.expand_path + 'views/'

  class MmUser
    include MongoMapper::Document

    puts "\n\n!!!!! WHATTTTTT \n\n"
    key :nickname, String, :required => true
    key :nickname_url, String, :required => true,:unique => true

    validates_presence_of :nickname
    validates_presence_of :nickname_url, :allow_blank => false
    validates_presence_of :password, :allow_blank => false
  end

  get '/' do
    @users = User.all
    @page_title = 'Home'
    haml :index
  end

  get '/login' do
    haml :login
  end

  get '/signup' do
    haml :signup
  end

  get '/user/:nickname_url' do
    @user = User.get(:nickname_url => params[:nickname_url])
    haml :show
  end

  post '/signup' do

    if not params[:user].has_key?('tos')
      @error = 'You must accept the Terms and Conditions'
      return haml :signup
    end

    @user = User.set(params[:user])

    if @user.valid && @user.id
      session[:user] = @user.id
      redirect '/'
    else
      @error =  "There were some problems creating your account: #{@user.errors}."
      haml :signup
    end
  end

  get '/settings/?:id?' do
    login_required
    redirect '/' unless current_user.id.to_s == params[:id] || current_user.admin?

    if params[:id]
      @user = User.get(:id => params[:id])
    else
      @user = current_user
    end

    haml :settings
  end

  post '/settings/?:id?' do
    login_required
    redirect "/" unless current_user.admin? || current_user.id.to_s == params[:id]
    user = User.get(:id => params[:id])
    user_attributes = params[:user]

    if params[:user][:password] == ""
        user_attributes.delete("password")
        user_attributes.delete("password_confirmation")
    end

    if user.update(user_attributes)
      redirect '/'
    else
      @error = "There were some problems with your updates: #{user.errors}."
      redirect "/settings/#{user.id}?"
    end
  end

  register Sinatra::SinatraAuthentication
end
