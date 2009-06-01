BITLY_RB = "#{RAILS_ROOT}/config/initializers/bitly.rb"
unless File.exists?(BITLY_RB)
  file = File.new(BITLY_RB, "w")
  file.puts <<-FILE
require 'bitly'

BITLY[:user] = "Change this to your bit.ly username"
BITLY[:api_key] = "Change this to your bit.ly API key"

FILE

else
  puts "#{BITLY_RB} seems to already exist, please ensure that BITLY[:api_key] and BITLY[:user] has been set."
end