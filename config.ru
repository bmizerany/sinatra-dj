require 'rubygems'
require 'bundler/setup'
require File.expand_path('../sinatra-dj', __FILE__)

run Sinatra::Application
