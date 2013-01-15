require 'bundler'
Bundler.require

require './app'

Seedling.set :project_name, 'Seedling'

use Rack::Session::EncryptedCookie, :expire_after => 3600*24*60, :secret => ENV['COOKIE_SECRET']

logger = Logger.new($stdout)
MongoMapper.connection = Mongo::Connection.new(ENV['DATABASE_HOST'], ENV['DATABASE_PORT'], :logger => logger)
MongoMapper.database = ENV['DATABASE']
MongoMapper.database.authenticate(ENV['DATABASE_USER'], ENV['DATABASE_PASSWORD'])

run Seedling
