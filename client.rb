#!/usr/bin/env ruby
require "socket"

class Client
	
	def initialize(chatserver)
		@chatserver = chatserver
		@request = nil
		@response = nil
		start_connection
		@info = false
	end

	def help
		puts "1) [list|LIST] lista los usuarios conectados"
		puts "2) [end|END] termina session en el chat"
		puts "3) [p:|P:][name]:[message] envia un mensaje privado"
		puts "4) [help|HELP] despliega este menu de ayuda"
	end

	def start_sends
		@request = Thread.new do
			loop {
				msg = get_input
				puts "message: #{msg}" unless @info
				if msg =~ /end/i and not @info
					send_msg "end"
					@chatserver.close
					Thread.kill @response
					Thread.kill @request
					Thread.main.stop
				elsif msg =~ /help/i
					help
				else
					send_msg msg
				end
			}
		end
	end

	def listen
		@response = Thread.new do
			loop {
				resp_msg = get_server_input
				p resp_msg
				if resp_msg =~ /^<\d+>/
					response_code = resp_msg[1,3]
					resp_msg = resp_msg[5..-1]
					@info = true
					case response_code
						when "200"
							# OK code
							puts "#{resp_msg}"
						when "400"
							puts "There is no rooms avaiable, create one."
							print "Room name: "
						when "401"
							puts "your name is not available, try again."
							exit
						when "404"
							puts "This chat room not exist, try again."
					end
				else
					@info = false
					puts "#{resp_msg}"
				end
			}
		end
	end

	private
	def start_connection
		puts "Enter your name or nickname (it must be unique)"
		name = get_input
		system("clear")
		help
		@chatserver.puts name
	end

	def get_input
		STDIN.gets.chomp
	end

	def send_msg(msg)
		@chatserver.puts msg
	end

	def get_server_input
		@chatserver.gets.chomp
	end
end

hostname = 'localhost'
port = ARGV[0].to_i
chatserver = TCPSocket.open(hostname,port)
client = Client.new chatserver
client.listen
client.start_sends

while Thread.main.alive?
	
end