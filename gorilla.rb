@w = false
@file = 'BUGS/BUGS.tdb'
@port = 8000
ARGV.each do |i|
	if i == '-f'
		@file = ARGV[ARGV.index(i)+1]
	end
	if i == '-p'
		@port = ARGV[ARGV.index(i)+1]
	end
	if i == '-w'
		@w = true
	end
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
def output(request, response)
	text = ""
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
		text += ERB.new(erb_text).result(binding)
	end
	if request.path.split('.')[-1] == 'css'
		response['Content-Type'] = 'text/css'
		text = File.new(request.path[1..-1],'r').readlines.join
	end
	return text
end
begin
	raise LoadError unless @w == false
	require 'rubygems'
	require 'mongrel'
	require 'erb'
	require 'db'
	require 'ostruct'
	require 'gorilla_mongrel'
rescue LoadError
	require 'webrick'
	require 'erb'
	require 'db'
	require 'gorilla_webrick'
end
