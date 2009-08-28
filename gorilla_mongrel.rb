#!/usr/bin/env ruby
require 'ostruct'
require 'rubygems'
require 'mongrel'
require 'erb'
require 'db'

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
			controllers = ['/index','/view', '/edit', '/delete', '/create', '/new', '/newprop', '/createprop', '/createprop2', '/editprop', '/deleteprop', '/reprop', '/reprop2']
			index = '/index'
			cur = ''
			controllers.each do |controller|
				if request.path.index(controller) != nil
					cur = controller
				end
			end
			eval File.read("default_conf.rb"), binding
			Dir.glob("helpers/*.rb").each do |helper|
				load helper
			end
			if File.exists?(@file + '.rb')
				eval File.read(@file + '.rb')
			end
			if controllers.index(cur) != nil or request.path == '/'
				head['Content-Type'] = "text/html"
				erb_text = ""
				File.open('views/header.html.erb', 'r') do |file|
					erb_text += file.read
				end
				file_name = ""
				if request.path == '/'
					file_name = "views/#{index}.html.erb"
				else
					p request.path
					file_name = "views#{cur}.html.erb"
				end
				File.open(file_name, 'r') do |file|
					erb_text += file.read
					file.close
				end
				File.open('views/footer.html.erb', 'r') do |file|
					erb_text += file.read
				end
				out.write ERB.new(erb_text).result(binding)
			end
			if request.path.split('.')[-1] == 'css'
				head['Content-Type'] = 'text/css'
				out.write File.new(request.path[1..-1],'r').readlines.join
			end
		end
	end
end

h= Mongrel::HttpServer.new("0.0.0.0", "8000")
h.register("/", Simple.new('BUGS/BUGS.tdb'))
h.run.join

=begin
class CustomServlet < HTTPServlet::AbstractServlet
	def initialize server, file
		super server
		@file = file
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
	end
	
	def do_GET(request, response)
		response.status = 200
		controllers = ['/index','/view', '/edit', '/delete', '/create', '/new', '/newprop', '/createprop', '/createprop2', '/editprop', '/deleteprop', '/reprop', '/reprop2']
		index = '/index'
		cur = ''
		controllers.each do |controller|
			if request.path.index(controller) != nil
				cur = controller
			end
		end
		eval File.read("default_conf.rb"), binding
		Dir.glob("helpers/*.rb").each do |helper|
			load helper
		end
		if File.exists?(@file + '.rb')
			eval File.read(@file + '.rb')
		end
		if controllers.index(cur) != nil or request.path == '/'
			response['Content-Type'] = "text/html"
			erb_text = ""
			File.open('views/header.html.erb', 'r') do |file|
				erb_text += file.read
			end
			file_name = ""
			if request.path == '/'
				file_name = "views/#{index}.html.erb"
			else
				p request.path
				file_name = "views#{cur}.html.erb"
			end
			File.open(file_name, 'r') do |file|
				erb_text += file.read
				file.close
			end
			File.open('views/footer.html.erb', 'r') do |file|
				erb_text += file.read
			end
			response.body += ERB.new(erb_text).result(binding)
		end
		if request.path.split('.')[-1] == 'css'
			response['Content-Type'] = 'text/css'
			response.body = File.new(request.path[1..-1],'r').readlines.join
		end
	end
	
	alias :do_POST :do_GET
end

if __FILE__ == $0
	file = 'BUGS/BUGS.tdb'
	port = 8000
	ARGV.each do |i|
		if i == '-f'
			file = ARGV[ARGV.index(i)+1]
		end
		if i == '-p'
			port = ARGV[ARGV.index(i)+1]
		end
	end
	# Mount servlets.
	s = HTTPServer.new(:Port => port, :MimeTypes =>  WEBrick::HTTPUtils::DefaultMimeTypes, :DocumentRoot => Dir.pwd)
	s.mount('/', CustomServlet, file)

	# Trap signals so as to shutdown cleanly.
	['TERM', 'INT'].each do |signal|
		trap(signal) {s.shutdown}
	end

	# Start the server and block on input
	s.start
end
=end