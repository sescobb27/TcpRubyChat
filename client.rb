#!/usr/bin/env ruby
require "socket"

hostname = 'localhost'
port = ARGV[0].to_i

chatserver = TCPSocket.open(hostname,port)
puts "Enter your name or nickname (it must be unique)"
name = STDIN.gets
system("clear")
chatserver.puts name
def help
	puts "1) [list|LIST] lista los usuarios conectados"
	puts "2) [end|END] termina session en el chat"
	puts "3) [p:|P:][name]:[message] envia un mensaje privado"
	puts "4) [help|HELP] despliega este menu de ayuda"
end
response = Thread.new do
	loop {
		resp_msg = chatserver.gets
		unless resp_msg.empty?
			puts "#{resp_msg}"
		else
			chatserver.close
		end
	}
end

request = Thread.new do
	help
	loop {
		msg = STDIN.gets.chomp
		puts "message: #{msg}"
		if msg =~ /end/i
			chatserver.puts "end"
			chatserver.close
			Thread.kill response
			Thread.kill request
		elsif msg =~ /help/i
			help	
		end
		chatserver.puts msg
	}
end

while request.alive?
	
end