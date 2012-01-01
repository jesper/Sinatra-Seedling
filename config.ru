require './app'

Seedling.set :project_name, 'Seedling'

use Rack::Session::Cookie, :secret => 'ch4ng3 m3!'
use Rack::Flash

logger = Logger.new($stdout)
MongoMapper.connection = Mongo::Connection.new('localhost', 27017, :logger => logger)
MongoMapper.database = 'sinatra-seedling'
MongoMapper.database.authenticate('sinatra-seedling', '')

run Seedling
