$:.unshift *Dir[File.dirname(__FILE__) + "/vendor/*/lib"]

require 'sinatra'
require 'sinatra/captcha'
require 'active_record'
require 'delayed_job'
require 'open-uri'

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
  @session = rand(1000) + 1000
  @translations = Translation.all(:order => 'created_at desc')
  erb :translations
end

post '/translations' do
  halt 401, "Invalid Captcha Answer" unless captcha_pass?
  Translation.create! :input => params[:input]
  redirect '/'
end
