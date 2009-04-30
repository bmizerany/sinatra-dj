$LOAD_PATH.unshift 'vendor/delayed_job/lib'

require 'sinatra'
require 'activerecord'
require 'delayed_job'

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

use_in_file_templates!

__END__

@@ translations

<h1>Pig Latin Translator</h1>
<h2>An example of Sinatra + DJ on Heroku</h2>
<h3>see the <a href="http://github.com/bmizerany/sinatra-dj">code</a></h3>

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
  <div><input type="submit" value="Submit" /></div>
</form>
