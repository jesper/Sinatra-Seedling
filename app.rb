require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'mongo_mapper'
require 'digest/sha1'
require 'rack-flash'
require 'sinatra-authentication'
require 'haml'

class Seedling < Sinatra::Base

  get '/' do
    @users = User.all
    @page_title = 'Home'
    haml :index
  end
  
  get '/login' do
    @page_title = 'Login'
    haml :login
  end
  
  get '/signup' do
    @page_title = 'Sign Up'
    haml :signup
  end
  
  post '/signup' do
    @user = User.set(params[:user])
    if @user.valid && @user.id
      session[:user] = @user.id
      if Rack.const_defined?('Flash')
        flash[:notice] = "Account created."
      end
      redirect '/'
    else
      if Rack.const_defined?('Flash')
        flash[:notice] = "There were some problems creating your account: #{@user.errors}."
      end
      redirect '/signup?' + hash_to_query_string(params['user'])
    end
  end
  
end
