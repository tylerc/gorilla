#!/usr/bin/env ruby
class Simple < Mongrel::HttpHandler
	def initialize file
		@file = file
	end
	
	def reload
		@db, @schema, @order = load_db(@file)
		if !@schema.empty?
			@schema.each_key do |key|
				if @schema[key] == "ID"
					@id_location = @order.index(key)
					@order2 = @order.clone
					@order2.delete_at @id_location
				end
			end
		else
			@id_location = 0
			@order2 = []
		end
		# @db_final is sacred, don't change it
		@db_final = @db.clone
	end
	
	def process(mongrel_request, response)
		reload
		response.start do |head,out|
			request = OpenStruct.new
			request.response = response
			def response.redirect(url)
				@header["Location"] = url
				@status = 302
			end
			request.query = Mongrel::HttpRequest.query_parse(mongrel_request.params['QUERY_STRING']).clone
			request.path = mongrel_request.params["REQUEST_PATH"].clone
			out.write output(request, head)
		end
	end
end

# Mount servlets.
h=Mongrel::HttpServer.new("0.0.0.0", @port)
h.register("/", Simple.new(@file))

# Trap signals so as to shutdown cleanly.
['TERM', 'INT'].each do |signal|
	trap(signal) {h.stop}
end

# Start the server and block on input
h.run.join
