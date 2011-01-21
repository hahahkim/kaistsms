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
	
	def sendSMS(sendhp, recvhp, msg)
		unless self.login?
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
			puts "Input recieve hp"
		end
		
		res=sms.form('f') do |f|
			f.sendHp=sendhp
			f.msglen=msg.bytesize
			f.toMessage=msg
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

m=KaistMail.new
if ARGV.length!=5
		  puts "wrong arguements\n[Kaist Mail ID] [Kaist Mail PW] [Send Phone Num] [Recv Phone Nums] [Message]\nYou can use seperator ';' for multiple recv phone nums" 

id,pw,shp,rhp,msg = ARGV

m.login(id,pw)
m.sendSMS(shp,rhp,msg)
