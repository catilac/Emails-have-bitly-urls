# Include hook code here
require 'emails_have_bitly_urls'
ActionMailer::Base.send(:include, EmailsHaveBitlyUrls)