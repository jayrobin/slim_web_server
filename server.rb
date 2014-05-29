require 'socket'

class Server
	FileNotFoundError = Class.new(StandardError)
	
	def initialize(port)
		@port = port
	end

	def run
		server = TCPServer.open(@port)

		loop do
			Thread.start(server.accept) do |client|
				header = client.read_nonblock(256)

				requested_resource = get_resource_from_header(header)
				client.puts get_resource(requested_resource)

				client.close
			end
		end
	end

	private

	def get_method_from_header(header)
		header.scan(/^(.*) .* HTTP/)[0][0]
	end

	def get_resource_from_header(header)
		header.scan(/^.* (.*) HTTP/)[0][0]
	end

	def get_response(status_code, reason, content, content_type = "text/html")
		response = "HTTP/1.1 #{status_code} #{reason}\r\n"
		response << "Content-type: #{content_type}\r\n"
		response << "Content-length: #{content.size}\r\n\r\n"
		response << "#{content}\r\n"
	end

	def get_resource(path)
		begin
			content = load_file(path)
			status_code = 200
			reason = "OK"
		rescue Exception => e
			# 404 error
			status_code = 404
			reason = "Not found"
			content = e.to_s
		end
		
		get_response(status_code, reason, content)
	end

	def load_file(path)
		File.read(".#{path}")
	end
end

server = Server.new(3001)
server.run