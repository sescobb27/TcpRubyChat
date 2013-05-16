#!/usr/bin/env ruby
require "socket"
class Chatserver
	
	def initialize(port, ip)
		@chatserver = TCPServer.open ip, port
		@connections = Hash.new
		@rooms = Hash.new
		@connections[:server] = @chatserver
		@connections[:rooms] = @rooms
	end

	def run
		loop {
			Thread.start(@chatserver.accept) do |client|
				connected = false
				nick_name = client.gets.chomp.to_sym
				room_name = ""
				if @connections[:rooms].empty?
					p "400"
					client.puts "400"
					room_name = client.gets.chomp.to_sym
					p room_name
					clients = Hash.new
					@connections[:rooms][room_name] = clients[nick_name] = client
					p @connections[:rooms][room_name]
				else
					@connections[:rooms].each do |room, client_dict|
						client_dict.each do |name, other_client|
							if client == other_client or nick_name == name
								connected = true
								client.puts "401"
							end
						end
					end
				end
				if not connected
					message = "Choose a room to enter in it.\n"
					@connections[:rooms].each { |room| message += room.to_s + "\n"}
					client.puts message
					room_name = client.gets.chomp.to_sym
					while not @connections[:rooms].include? room_name
						client.puts "This chat room not exist"
						room_name = client.gets.chomp.to_sym
					end
					@connections[:rooms][room_name][nick_name] = client
					puts "#{@connections}"
					client.puts "you're now connected to the chat room."
					get_msg room_name, nick_name, client
				end
				connected = false
			end
		}
	end

	private
	def private_message(room_name, msg, to_client, from_client)
		clients = @connections[:rooms][room_name]
		if clients.include? to_client
			clients[to_client].puts "private message from "+from_client+": "+msg
		else
			raise "No user with this name or is gone."
		end
	end

	def get_msg(room_name, nick_name, client)
		loop {
			msg = client.gets.chomp
			if @connections[:rooms][room_name].size == 2
				client.puts "you are alone"
			elsif msg =~ /^p:/i
				# private_message
				msg = msg.split(':')
				name = msg[1].to_sym
				msg = msg[2]
				begin
					private_message room_name, msg, name, nick_name.to_s
				rescue Exception => e
					client.puts "#{e.message}"
				end
			elsif msg =~ /end/i
				@connections[:rooms][room_name].delete nick_name
				client.close
			elsif msg =~ /list/i
				@connections[:rooms][room_name].each do |nick, client|
					if !nick.equal? :server and !nick.equal? nick_name
						client.puts nick.to_s
					end
				end
			else
				broadcast_message room_name, msg, nick_name
			end
		}
	end

	def broadcast_message(room_name, msg, omit_client)
		@connections[:rooms][room_name].each do |nick_name, client|
			if !nick_name.equal? :server and !nick_name.equal? omit_client
				client.puts omit_client.to_s+": " + msg
			end
		end
	end
end

def validate_ip(ip)
	unless ip =~ /\A(\d){1,3}\.(\d){1,3}\.(\d){1,3}\.(\d){1,3}\z/ or ip == "localhost"
		puts "Error ip format must be ###.###.###.### or localhost"
		exit
	end
end

def validate_port(port)
	unless port =~ /^[0-9]+$/
		puts "Error port must be a number"
		exit
	end
end

tag = ARGV[0]
tag2 = ARGV[2]
if tag =~ /-p/
	port = ARGV[1].chomp
	validate_port port
elsif tag =~ /-ip/
	ip = ARGV[1].chomp
	validate_ip ip
else
	puts "Error Args, must be -p or -ip"
	exit
end

if tag2 =~ /-p/
	port = ARGV[3].chomp
	validate_port port
elsif tag2 =~ /-ip/
	ip = ARGV[3].chomp
	validate_ip ip
else
	puts "Error Args, must be -p or -ip"
	exit
end
chat = Chatserver.new port, ip
chat.run