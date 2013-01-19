require 'bundler'
Bundler.require

require './app'

Seedling.set :project_name, 'Seedling'
Seedling.set :google_analytics, ENV['GOOGLE_ANALYTICS']

use Rack::Session::EncryptedCookie, :expire_after => 3600*24*60, :secret => ENV['COOKIE_SECRET']
use Rack::Csrf, :raise => true

logger = Logger.new($stdout)
MongoMapper.connection = Mongo::Connection.new(ENV['DATABASE_HOST'], ENV['DATABASE_PORT'], :logger => logger)
MongoMapper.database = ENV['DATABASE']
MongoMapper.database.authenticate(ENV['DATABASE_USER'], ENV['DATABASE_PASSWORD'])

run Seedling
