$:.unshift *Dir[File.dirname(__FILE__) + "/vendor/*/lib"]

require 'sinatra'
require 'active_record'
require 'delayed_job'
require 'open-uri'

configure do
  config = YAML::load(File.open('config/database.yml'))
  environment = Sinatra::Application.environment.to_s
  ActiveRecord::Base.logger = Logger.new($stdout)
  ActiveRecord::Base.establish_connection(config[environment])
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

  def displayed!
    self.displayed = true
    save!
  end

  def self.english_to_pig_latin(text)
    text.split.map do |word|
      word = word.downcase
      if word.length <= 2
        word
      else
        case word
        when /^[aeiouy]/
          "#{word}ay".downcase
        else
          word.sub(/([^aeiouy]+)([aeiouy])(.*)/) { "#$2#$3#$1ay" }
        end
      end
    end.join(" ")
  end
end

get '/' do
  @session = rand(1000) + 1000
  translations = Translation.all(:order => 'created_at desc')
  translations.select { |t| t.output }.each { |t| t.displayed! }
  @translation_class = 'latest'
  @pending_class = 'pending'
  haml :index, :locals => { :translations => translations }
end

get '/latest' do
  latest = Translation.find(:all, :order => 'created_at desc')
  latest = latest.select { |t| !t.displayed }
  latest.each { |t| t.displayed! }
  haml :translation, :locals => { :translations => latest },
    :layout => false
end

post '/translations' do
  Translation.create! :input => params[:input]
  redirect '/'
end
