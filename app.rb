require 'rubygems'
require 'sinatra'
require 'mongo_mapper'
require 'digest/sha1'
require 'rack-flash'
require 'sinatra-authentication'
require 'haml'

use Rack::Session::Cookie, :secret => 'ch4ng3 m3!'
use Rack::Flash

logger = Logger.new($stdout)
MongoMapper.connection = Mongo::Connection.new('localhost', 27017, :logger => logger)
MongoMapper.database = 'sinatra-seedling'
MongoMapper.database.authenticate('sinatra-seedling', '')

set :sinatra_authentication_view_path, Pathname(__FILE__).dirname.expand_path + 'views/'

get '/' do
  @users = User.all
  haml :index
end

get '/signup' do
  haml :signup
end
