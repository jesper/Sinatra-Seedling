require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'mongo_mapper'
require 'rack-flash'
require 'sinatra-authentication'
require 'haml'

class Seedling < Sinatra::Base
  register Sinatra::SinatraAuthentication
  set :sinatra_authentication_view_path, Pathname(__FILE__).dirname.expand_path + 'views/'

  get '/' do
    @users = User.all
    @page_title = 'Home'
    haml :index
  end

end
