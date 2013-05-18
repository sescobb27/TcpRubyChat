#!/usr/bin/env ruby
require "socket"
require_relative "shell_input"
class Chatserver
	
	def initialize(port, ip)
		@chatserver = TCPServer.open ip, port
		@connections = Hash.new
		@rooms = Hash.new
		@clients = Hash.new
		@connections[:server] = @chatserver
		@connections[:rooms] = @rooms
		@connections[:clients] = @clients
	end

	def run
		loop {
			Thread.start(@chatserver.accept) do |client|
				connected = false
				nick_name = client.gets.chomp.to_sym
				room_name = ""
				if @connections[:rooms].empty?
					client.puts "<400>"
					room_name = client.gets.chomp.to_sym
					crear_sala room_name, nick_name, client
					connected = true
				else
					@connections[:clients].each do |name, other_client|
						puts "#{name}"
						if client == other_client or nick_name == name
							connected = true
							client.puts "<401>"
							Thread.kill self
						end
					end
				end
				if not connected
					message = "<200>Choose a room to enter in it.\n"
					message += "==============Rooms=================\n"
					@connections[:rooms].each_key { |room| message += room.to_s + "\n"}
					message += "==============End Rooms=============\n"
					client.puts message
					room_name = client.gets.chomp.to_sym
					while not @connections[:rooms].include? room_name
						if nombre_valido? room_name
							client.puts "<404>"
							answer = client.gets.chomp
							if answer =~ /(y|s)/i
								crear_sala room_name, nick_name, client
								connected = true
								break
							else
								client.puts "<300>"
							end
						else
							client.puts "<405>"
						end
						room_name = client.gets.chomp.to_sym
					end
					if not connected
						@connections[:clients][nick_name] = client
						@connections[:rooms][room_name] << nick_name
					end
				end
				puts "#{@connections}"
				client.puts "you're now connected in #{room_name} chat room."
				get_msg room_name, nick_name, client
				connected = false
			end
		}
	end

	private
	def nombre_valido?(room_name,command_line = false)
		return room_name =~ /^(\w){3,}$/i unless command_line
		room_name = room_name =~ /^<(\w){3,}>$/i ? room_name[1..-2].to_sym : false
	end

	def crear_sala(room_name, nick_name, client = nil)
		@connections[:clients][nick_name] = client if client
		@connections[:rooms][room_name] = []
		@connections[:rooms][room_name] << nick_name
	end

	def private_message(room_name, msg, to_client, from_client)
		if @connections[:rooms][room_name].include? to_client
			@connections[:clients][to_client].puts "private message from #{from_client}: #{msg}"
		else
			raise "No user with this name or is gone."
		end
	end

	def get_msg(room_name, nick_name, client)
		loop {
			msg = client.gets.chomp
			if @connections[:rooms][room_name].size == 1 and 
				client.puts "you are alone"
			elsif msg =~ /^p:\w+:.+$/i
				# private_message
				msg = msg.split(':',3)
				name = msg[1].to_sym
				msg = msg[2]
				begin
					private_message room_name, msg, name, nick_name.to_s
				rescue Exception => e
					client.puts "#{e.message}"
				end
			elsif msg =~ /^<new room>/i
				new_room = nombre_valido? msg[10..-1].strip, true
				if new_room and not @connections[:rooms].include? new_room
					@connections[:rooms][room_name].delete nick_name
					crear_sala new_room, nick_name
					room_name = new_room
					client.puts "<200>Chat room successfully created, you are now in it."
				else
					client.puts "<405>" unless new_room
					client.puts "<402>" unless condition
				end
			elsif msg =~ /^end$/i
				@connections[:rooms][room_name].delete nick_name
				@connections[:clients].delete nick_name
				client.close
			elsif msg =~ /^list$/i
				message = ""
				@connections[:rooms][room_name].each do |nick|
					unless nick == nick_name
						message += "#{nick.to_s}\n"
					end
				end
				client.puts message
			else
				broadcast_message room_name, msg, nick_name
			end
		}
	end

	def broadcast_message(room_name, msg, omit_client)
		@connections[:rooms][room_name].each do |nick_name|
			unless nick_name == omit_client
				@connections[:clients][nick_name].puts "#{omit_client.to_s}: #{msg}"
			end
		end
	end
end
port, ip = Shell::input
chat = Chatserver.new port, ip
chat.run