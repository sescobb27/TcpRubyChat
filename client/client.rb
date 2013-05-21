#!/usr/bin/env ruby
require "socket"
require_relative "../helpers/shell_input"
require_relative "../helpers/sender"

class Client
	
	def initialize(chatserver)
		@chatserver = chatserver
		@request = nil
		@response = nil
		start_connection
		@info = false
	end

	def help
		puts "..........................help.............................."
		puts "1) [list|LIST]!-all!!-sala! lista los usuarios conectados en esa sala,\n   lo que esta dentro de !! es opcional"
		puts "2) [<end>|<END>] termina session en el chat"
		puts "3) [p:|P:][name]:[message] envia un mensaje privado"
		puts "4) [help|HELP] despliega este menu de ayuda"
		puts "5) si desea crear una sala nueva, cuando vaya a escoger\n   una de las salas, coloque el nombre de la nueva sala,\n   recuerde que debe tener un nombre unico o copie <new room><NOMBRE>,\n   siendo el nombre de 3 o mas caracteres, (LETRA|NUMERO|_)"
		puts "6) si desea cambiar de sala copie <change><NOMBRE>"
	end

	def start_sends
		@request = Thread.new do
			loop {
				msg = get_input
				send = true
				if msg =~ /^<end>$/i and not @info
					send_msg "<end>"
					@chatserver.close
					Thread.kill @response
					Thread.main.kill
					exit
				elsif msg =~ /^help$/i
					help
				elsif msg.size > 160
					puts "message too long"
					send = false
				elsif not @info and not msg =~ /^</
					puts "message: #{msg}"
					send = true
				end
					send_msg(msg) if send
			}
		end
	end

	def listen
		@response = Thread.new do
			loop {
				resp_msg = get_server_input
				if resp_msg =~ /^<\d+>/
					response_code = resp_msg[1,3]
					@info = true
					case response_code
						when "200"
							# OK code
							puts "#{resp_msg[5..-1]}"
						when "300"
							# information to resend
							puts "Choose an other chat room name."
						when "400"
							puts "There is no rooms avaiable, create one."
							print "Room name: "
						when "401"
							puts "Your name is not available, try again."
							exit
						when "402"
							puts "This chat room already exist, try again."
						when "404"
							puts "This chat room not exist, do you want to create it?(Y|S|ANYTHING)"
						when "405"
							puts "Error invalid chat room name."
						when "500"
							puts "The Server is down now"
							exit
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
		send_msg name
	end

	def get_input
		STDIN.gets.chomp
	end

	def send_msg(msg)
		# @chatserver.puts msg
		Sender.send_message({server: @chatserver}, msg)
	end

	def get_server_input
		@chatserver.gets.chomp
	end
end

port, ip = Shell::input
chatserver = TCPSocket.open(ip, port)
client = Client.new chatserver
client.listen
client.start_sends

begin
	while Thread.main.alive?
	
	end
rescue Exception => e
	chatserver.puts "<end>"
	chatserver.close
	Thread.list.each do |thread|
		thread.kill
	end
end