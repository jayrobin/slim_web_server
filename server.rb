require 'socket'

class Server
	def initialize(port)
		@port = port
	end

	def run
		server = TCPServer.open(@port)

		loop do
			Thread.start(server.accept) do |client|
				header = client.read_nonblock(256)

				method = get_http_method(header)
				resource = get_resource(header)

			  client.close
			end
		end
	end

	def get_http_method(header)
		header.scan(/^(.*) .* HTTP/)[0][0]
	end

	def get_resource(header)
		header.scan(/^.* (.*) HTTP/)[0][0]
	end

	def get_response(status_code, reason, content, content_type = "text/html")
		response = "HTTP/1.1 #{status_code} #{reason}\r\n"
		response << "Content-type: #{content_type}\r\n"
		response << "Content-length: #{content.size}\r\n\r\n"
		response << "#{content}\r\n"
	end
end

server = Server.new(3001)
server.run