require 'rubygems'
require 'mechanize'
require 'kaistmail.rb'

m = KaistMail.new
m.login
if m.login?
		  puts "Login Success"
else
		  puts "Login Fail"
end


