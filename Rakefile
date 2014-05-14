require 'rubygems'
require 'bundler/setup'
require File.expand_path('../sinatra-dj', __FILE__)

desc "One time task to setup on Heroku"
task :create do
  sh "heroku create" unless `git remote` =~ /heroku/
  sh "heroku config:add BUNDLE_WITHOUT='development test'"
  sh "git push heroku master"
  sh "heroku rake db:migrate"
  sh "heroku workers 1"
  sh "heroku open"
end

namespace :db do
  task :migrate do
    ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"].tap { |v| v.to_i if v })
  end
end

begin
  require 'delayed/tasks'
rescue LoadError
  STDERR.puts "Run `rake gems:install` to install delayed_job"
end
