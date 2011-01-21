require 'rubygems'
require 'mechanize'

class KaistMail
	def login userid, userpasswd
		m = Mechanize.new
		mail = m.get 'http://mail.kaist.ac.kr'
		main = mail.frame('main').click
		@login = main.form('login') do |f|
			f.USERS_ID = userid
			f.USERS_PASSWD = userpasswd
			f.action = 'https://mail.kaist.ac.kr/nara/servlet/user.UserServ'
			f.cmd = 'login'
		end.submit
	end

	def login?
		if @login.body=~/img_msgError.gif/
				false
		else
				true
		end
	end
end

