class Sender
	def self.send_message(to = {}, message)
		to = to[:client] ? to[:client] : to[:server]
		to.puts message
		# if to[:client]
		# 	to[:client].puts message
		# elsif to[:server]
		# 	to[:server].puts message
		# end
	end
end