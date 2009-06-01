require 'test_helper'


class BitlyUrlMailer < ActionMailer::Base
  self.template_root = File.join(RAILS_ROOT, 'vendor/plugins/emails_have_bitly_urls/test/fixtures')
  
  def weekly_link_digest(recipient)
    @recipients = recipient
    @subject    = "These r my fav links"
    @from       = "test@example.com"
    @sent_on    = Time.local 2004, 12, 12
    @body       = { "recipient" => recipient }
    @content_type= "text/html"
  end
end


class EmailsHaveBitlyUrlsTest < ActiveSupport::TestCase  
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.raise_delivery_errors = true
    ActionMailer::Base.deliveries = []

    @original_logger = BitlyUrlMailer.logger
    @recipient = 'chirag@example.com'
    
  end
  
  test "Bit.ly API credentials have been set" do
    assert BITLY[:user]    != "Change this to your bit.ly username"
    assert BITLY[:api_key] != "Change this to your bit.ly API key"
  end
  
  test "links get compressed" do
    bitly = Bitly.new(BITLY[:user], BITLY[:api_key])
    @facebook   = bitly.shorten("http://www.facebook.com").short_url
    @google     = bitly.shorten("http://www.google.com").short_url
    @youtube    = bitly.shorten("http://www.youtube.com").short_url
    @railsbrain = bitly.shorten("http://www.railsbrain.com").short_url
    assert_equal BitlyUrlMailer.create_weekly_link_digest(@recipient).parts.first.body + "\n",
<<-OUTPUT
http://bit.ly/17OFYz  This is meetup.
#{@google}      I like this website okay.
#{@facebook}    this is my favorite website.
#{@youtube}     this is my favorite website.

Oh yeah #{@railsbrain}
OUTPUT

  end
  
  test "links aren't compressed when exception is thrown" do
    # Remove creds to cause exception
    original_user = BITLY[:user]
    original_api_key = BITLY[:api_key]
    BITLY[:user] = ""
    BITLY[:api_key] = ""

    @facebook = "http://www.facebook.com"
    @google = "http://www.google.com"
    @youtube = "http://www.youtube.com"
    @railsbrain = "http://www.railsbrain.com"

    assert_equal BitlyUrlMailer.create_weekly_link_digest(@recipient).parts.first.body + "\n",
<<-OUTPUT
http://bit.ly/17OFYz  This is meetup.
#{@google}      I like this website okay.
#{@facebook}    this is my favorite website.
#{@youtube}     this is my favorite website.

Oh yeah #{@railsbrain}
OUTPUT

    # restore credentials
    BITLY[:user] = original_user
    BITLY[:api_key] = original_api_key
  end
end