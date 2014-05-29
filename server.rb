require 'socket'

port = 3001
server = TCPServer.open(port)

loop do
	Thread.start(server.accept) do |client|
	  client.puts "Connection acknowledged"
	  client.close
	end
end