module Shell
	def self.validate_ip(ip)
		unless ip =~ /\A(\d){1,3}\.(\d){1,3}\.(\d){1,3}\.(\d){1,3}\z/ or ip == "localhost"
			puts "Error ip format must be ###.###.###.### or localhost"
			exit
		end
	end

	def self.validate_port(port)
		unless port =~ /^[0-9]+$/
			puts "Error port must be a number"
			exit
		end
	end

	def self.input
		tag = ARGV[0]
		tag2 = ARGV[2]
		port = nil
		ip = nil
		if tag =~ /^-p$/ and tag2 =~ /^-ip$/
			port = ARGV[1].chomp
			Shell.validate_port port
			ip = ARGV[3].chomp
			Shell.validate_ip ip
		elsif tag =~ /^-ip$/ and tag2 =~ /^-p$/
			ip = ARGV[1].chomp
			Shell.validate_ip ip
			port = ARGV[3].chomp
			Shell.validate_port port
		else
			puts "Error Args, must be -p or -ip"
			exit
		end
		return port,ip
	end
end