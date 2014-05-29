require 'socket'

def get_http_method(header)
	header.scan(/^(.*) .* HTTP/)[0]
end

def get_resource(header)
	header.scan(/^.* (.*) HTTP/)[0]
end

port = 3001
server = TCPServer.open(port)

loop do
	Thread.start(server.accept) do |client|
		header = client.read_nonblock(256)

		method = get_http_method(header)
		resource = get_resource(header)

	  client.close
	end
end