$LOAD_PATH.unshift 'vendor/delayed_job/lib'

require 'sinatra'
require 'activerecord'
require 'delayed_job'

require File.dirname(__FILE__) + '/lib/translation'

configure do
  config = YAML::load(File.open('config/database.yml'))
  environment = Sinatra::Application.environment.to_s
  ActiveRecord::Base.logger = Logger.new($stdout)
  ActiveRecord::Base.establish_connection(
    config[environment]
  )
end

get '/' do
  @translations = Translation.all(:order => 'created_at desc')
  erb :translations
end

post '/translations' do
  Translation.create! :input => params[:input]
  redirect '/'
end
