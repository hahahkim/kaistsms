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
		login?
	end

	def login?
		if @login.body=~/img_msgError.gif/
				false
		else
				true
		end
	end
	
	def sendSMS(sendhp, recvhp, msg)
		unless login?
			puts "Login Fail"
			return false
		end
		
		if msg.bytesize > 80
			puts "message is too long"
			return false
		end

		sms=@login.link(:text => 'SMS').click
		recvhparr=recvhp.split(";").delete_if{|n| !(n=~/^\d+$/)}
		
		if recvhparr.empty?
			puts "Input receive phone number"
			return false
		end
		
		res=sms.form('f') do |f|
			f.sendHp=sendhp
			f.msglen=msg.bytesize
			f.toMessage=msg.encode("UTF-8")
			f.receiveHp=recvhparr
			f.radiobutton('type').value='0'
		end.submit
		
		try,success,remain=res.search('//td[@height="24"]/span[@class="t_menu_vioB"]').map(&:text).map(&:to_i)
		if try==success
			puts "Send Message Success. #{success} Sent, #{remain} Remains."
			return true
		else
			puts "#{success} of #{try} Sent, #{remain} Remains."
			return false
		end


	end
end

if __FILE__==$0
  # Find the parent directory of this file and add it to the front
  # of the list of locations to look in when using require
  $:.unshift File.join(File.dirname(__FILE__),'..')   


	if ARGV.length!=5
			puts "wrong arguements"
			puts "[Kaist Mail ID] [Kaist Mail PW] [Send Phone Num] [Recv Phone Nums] [Message]"
			puts "You can use seperator ';' for multiple recv phone nums" 
			puts "Ex) ruby kaistsms.rb hahah 123456 01012341234 01012341234;01043214321 hello"
			exit
	end


	id,pw,shp,rhp,msg = ARGV

	m=KaistMail.new
	m.login(id,pw)
	m.sendSMS(shp,rhp,msg)
end
