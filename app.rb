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
  
end
