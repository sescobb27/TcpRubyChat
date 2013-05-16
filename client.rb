#!/usr/bin/env ruby
require "socket"

hostname = 'localhost'
port = ARGV[0].to_i

chatserver = TCPSocket.open(hostname,port)
puts "Enter your name or nickname (it must be unique)"
name = STDIN.gets.chomp
system("clear")
chatserver.puts name

def help
	puts "1) [list|LIST] lista los usuarios conectados"
	puts "2) [end|END] termina session en el chat"
	puts "3) [p:|P:][name]:[message] envia un mensaje privado"
	puts "4) [help|HELP] despliega este menu de ayuda"
end

def start_messages
	request = Thread.new do
		create_or_choose_room
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
end

def create_or_choose_room
	room_name = ""
	while room_name.empty?
		room_name = STDIN.gets.chomp
	end
	chatserver.puts room_name
end

response = Thread.new do
	loop {
		resp_msg = chatserver.gets.chomp
		p resp_msg
		case resp_msg
			when "400"
				puts "There is no rooms avaiable, create one."
				print "Room name: "
				create_or_choose_room
				start_messages
			when "401"
				puts "your name is not available try again."
				exit
			else
				puts "#{resp_msg}"
		end
	}
end

while response.alive?
	
end