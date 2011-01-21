require 'rubygems'
require 'mechanize'

class KaistMail
	def initialize
	end
	
	def login
		m = Mechanize.new
		mail = m.get 'http://mail.kaist.ac.kr'
		main = mail.frame('main').click
		print "input id : "
		userid = gets.chomp
		print "input passwd : "
		userpasswd = gets.chomp
		@login = main.form('login') do |f|
			f.USERS_ID = userid
			f.USERS_PASSWD = userpasswd
			f.action = 'https://mail.kaist.ac.kr/nara/servlet/user.UserServ'
			f.cmd = 'login'
		end.submit
		if login.body=~/img_msgError.gif/
			puts "Login Error"
			nil
		else
			puts "Login Success"
			@login
		end
	end
end

