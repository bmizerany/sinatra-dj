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

class Translation < ActiveRecord::Base
  after_create :queue

  def queue
    Delayed::Job.enqueue self
  end

  def perform
    self.output = self.class.english_to_pig_latin(input)
    save!
  end

  def self.english_to_pig_latin(text)
    text.split.map do |word|
      if word.length <= 2
        word
      else
        (word[1,9999] + word[0,1] + "ay").downcase
      end
    end.join(" ")
  end
end

get '/' do
  @translations = Translation.all(:order => 'created_at desc')
  erb :translations
end

post '/translations' do
  Translation.create! :input => params[:input]
  redirect '/'
end
