#!/usr/bin/env ruby

include WEBrick

class CustomServlet < HTTPServlet::AbstractServlet
	def initialize server, file
		super server
		@file = file
		reload
	end
	
	def do_GET(request, response)
		response.status = 200
		def response.redirect(url)
			set_redirect(HTTPStatus::Found, url)
		end
		response.body = output(request, response, binding)
	end
	
	alias :do_POST :do_GET
end

# Mount servlets.
s = HTTPServer.new(:Port => @port, :MimeTypes =>  WEBrick::HTTPUtils::DefaultMimeTypes, :DocumentRoot => Dir.pwd)
s.mount('/', CustomServlet, @file)

# Trap signals so as to shutdown cleanly.
['TERM', 'INT'].each do |signal|
	trap(signal) {s.shutdown}
end

# Start the server and block on input
s.start
