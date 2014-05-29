require 'socket'
require 'yaml'

class Server
	def initialize(port, root, error_file)
		@port = port
		@root = root
		@error_file = error_file

		@content_types = load_content_types("content_types.yml")
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
			file_type = path.scan(/\.(.*)$/)[0][0] || "html"

			content = load_file(path)

			content_type = get_content_type(file_type)

			status_code = 200
			reason = "OK"
		rescue Exception => e
			# 404 error
			status_code = 404
			reason = "Not found"
			content_type = "text/html"
			content = create_error_output(e.to_s)
		end
		
		get_response(status_code, reason, content, content_type)
	end

	def load_file(path)
		path = @root if path == "/"

		File.read(".#{path}")
	end

	def create_error_output(error)
		begin
			content = load_file(@error_file)
			content.gsub!("<%= yield %>", error)
		rescue
			content = error
		end

		content
	end

	def get_content_type(extension)
		type = case extension
		when "html", "txt" then "text"
		when "jpg", "jpeg", "png", "bmp" then "image"
		end

		"#{type}/#{extension}"
	end

	def load_content_types(yml_file)
		YAML::load_file(yml_file)
	end
end

port = ARGV[0] || 3001
root = ARGV[1] || "/index.html"
error_file = ARGV[2] || "/error.html"

server = Server.new(port, root, error_file)
server.run