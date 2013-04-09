#!/usr/bin/env ruby
require "socket"
class Chatserver
	
	def initialize(port)
		@chatserver = TCPServer.open port
		@connections = Hash.new
		# @connections.push @chatserver
		@connections[:server] = @chatserver
	end

	def run
		loop {
			Thread.start(@chatserver.accept) do |client|
				connected = false
				@connections.each do |name, other_client|
					if client == other_client
						connected = true
					end
				end
				if not connected
					nick_name = client.gets.chomp.to_sym
					@connections[nick_name] = client
					puts "#{@connections}"
					client.puts "you're now connected to the chat room"
					get_msg nick_name, client
				end
				connected = false
			end
		}
	end

	private
	def private_message(msg, to_client, from_client)
		if @connections.include? to_client
			@connections[to_client].puts "private message from "+from_client+": "+msg
		else
			raise "No user with this name or is gone"
		end
	end

	def get_msg(nick_name, client)
		loop {
			msg = client.gets
			if msg =~ /^p:/i
				# private_message
				msg = msg.split(':')
				name = msg[1].to_sym
				msg = msg[2]
				begin
					private_message msg, name, nick_name.to_s
				rescue Exception => e
					client.puts "#{e.message}"
				end
			elsif msg =~ /end/i
				@connections.delete nick_name
				client.close
			elsif msg =~ /list/i
				@connections.each do |nick, client_con|
					if !nick.equal? :server and !nick.equal? nick_name
						client.puts nick.to_s
					end
				end
			else
				broadcast_message msg, nick_name
			end
		}
	end

	def broadcast_message(msg, omit_client)
		@connections.each do |nick_name, client|
			if !nick_name.equal? :server and !nick_name.equal? omit_client
				client.puts omit_client.to_s+": " + msg
			end
		end
	end
end

chat = Chatserver.new ARGV[0].to_i
chat.run