require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'mongo_mapper'
require 'rack-flash'
require 'sinatra-authentication'
require 'haml'

class Seedling < Sinatra::Base
  set :sinatra_authentication_view_path, Pathname(__FILE__).dirname.expand_path + 'views/'

  get '/' do
    @users = User.all
    @page_title = 'Home'
    haml :index
  end

  get '/login' do
    redirect '/'
  end

  helpers do
    def login_box
      if not logged_in?
        haml :login
      else
        haml :logout
      end
    end
  end

  register Sinatra::SinatraAuthentication
end
