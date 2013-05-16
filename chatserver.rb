#!/usr/bin/env ruby
require "socket"
class Chatserver
	
	def initialize(port)
		@chatserver = TCPServer.new port
		@connections = Array.new
		@connections.push @chatserver
	end

	def run
		msg = nil
		loop {
			# 1) IO.select takes a set of sockets and waits until it's possible
			# to read or write with them (or if error happens). It returns sockets 
			# event happened with.
			# 2) array contains sockets that are checked for events. In this case
			# i specify only sockets for reading.
			# 3) IO.select returns an array of arrays of sockets. Element 0 contains
			# sockets you can read from, element 1 - sockets you can write to and
			# element 2 - sockets with errors.
			reading_request = IO.select @connections

			if reading_request != nil
				# When the server starts, the only connection present is the
				# server socket. Therefore, you're waiting for a client to connect.
				for sock in reading_request[0]
					p reading_request[0]
					# if the reading request is for the chatserver it's because 
					# a new client is attempting to connect
					if sock.equal? @chatserver
						puts "nueva conexion"
						new_connection
					elsif sock.eof? or (msg = sock.gets) =~ /end/i
						sock.close
						@connections.delete sock
					elsif msg =~ /^p:/i
						# private_message
					else
						broadcast_message msg,sock
					end
				end
			end
		}
	end

	def private_message(msg, to_client)
		
	end

	private
	def broadcast_message(msg, omit_client)
		@connections.each do |client|
			if !client.equal? @chatserver and !client.equal? omit_client
				client.puts msg
			end
		end
	end

	def new_connection
		new_client = @chatserver.accept
		@connections.push new_client
		new_client.puts "you're now connected to the chat room"
		new_connection_msg = "Client joined #{new_client.peeraddr[2]}:#{new_client.peeraddr[1]}\n"
		broadcast_message new_connection_msg, new_client
	end
end

chat = Chatserver.new ARGV[0].to_i
chat.run