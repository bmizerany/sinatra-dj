require 'open-uri'

module Sinatra
  module Captcha
    def captcha_pass?
      session = params[:captcha_session].to_i
      answer  = params[:captcha_answer].gsub(/\W/, '')
      open("http://captchator.com/captcha/check_answer/#{session}/#{answer}").read.to_i.nonzero? rescue false
    end

    def captcha_session
      @captcha_session ||= rand(9000) + 1000
    end

    def captcha_answer_tag
      "<input id=\"captcha-answer\" name=\"captcha_answer\" type=\"text\" size=\"10\"/>"
    end

    def captcha_image_tag
      "<input name=\"captcha_session\" type=\"hidden\" value=\"#{captcha_session}\"/>\n" +
      "<img id=\"captcha-image\" src=\"http://captchator.com/captcha/image/#{captcha_session}\"/>"
    end
  end

  helpers Captcha
end
