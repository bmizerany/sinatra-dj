$:.unshift *Dir[File.dirname(__FILE__) + "/vendor/*/lib"]

require 'sinatra'
require 'sinatra/captcha'
require 'activerecord'
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

use_in_file_templates!

__END__

@@ translations

<h1>Pig Latin Translator</h1>
<h2>An example of <a href="http://www.sinatrarb.com">Sinatra</a> + <a href="http://github.com/tobi/delayed_job/">DJ (Delayed Job)</a> on Heroku</h2>
<h3>See the <a href="http://github.com/bmizerany/sinatra-dj">code</a></h3>

<% @translations.each do |translation| %>
  <ul>
    <li>
      <span><%= translation.input %></span>
      <span>&rarr;</span>
      <span><%= translation.output || '<i>...pending...</i>' %></span>
    </li>
  </ul>
<% end %>

<hr/>

<h2>New Translation</h2>
<form method="post" action="/translations">
  <div><textarea rows="3" cols="80" name="input">Enter text to translate</textarea></div>
  <p><%= captcha_image_tag %></p>
  <p><%= captcha_answer_tag %></div>
  <div><input type="submit" value="Submit" /></div>
</form>
