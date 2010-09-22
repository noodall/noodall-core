require 'noodall-core'
require 'rspec'
require 'database_cleaner'
require 'factory_girl'
require 'faker'

MongoMapper.connection = Mongo::Connection.new
MongoMapper.database = 'noodal-core-test'

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean_with(:truncation)
 
Noodall::Node.slots :main, :wide, :small

require 'factories/node'
require 'factories/component'

Rspec.configure do |config|
  config.mock_with :rspec
  
  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
  
end
