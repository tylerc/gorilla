#!/usr/bin/env ruby
require 'webrick'
require 'db'
include WEBrick

class CustomServlet < HTTPServlet::AbstractServlet
	def initialize server
		super server
		if ARGV[0] == nil
			puts "No file specified, using default"
			@file = "EXAMPLE2.tdb"
		else
			@file = ARGV[0]
		end
		@db, @schema, @order = load(@file)
		# exception handling block, in case of an empty starting file
		begin
			@id_location = 0#{request.query.join('&')}&
			@schema.each { |pair| if pair[1] == "ID" ; @id_location = @order.index(pair[0]) ; end }
			@order2 = @order.clone
			@order2.delete_at(@id_location)
		rescue
			puts "FAIL"
			@order = []
			@order2 = []
			@db = {}
			@schema = {}
		end
	end

	def filter_query query
		text = '?'
		query.each do |key|
			if key.to_s[0..5] == 'filter'
				text += key + "&"
			end
		end
		return text
	end

	def filter_query_remove query, prop
		text = ""
		props = []
		query.each do |key|
			if key[0..5] == 'filter' and HTTPUtils.unescape(key.split(';')[2]) == prop.downcase
				tmp = query.clone
				tmp.delete key
				text += "<td><a href='#{filter_query(tmp)}'>#{prop}</a></td>"
				props += [prop]
			end
			# LSTRING support
			is = false
			@schema.values.each do |x|
			
			end
			if key[0..5] == 'filter' and @schema[key.split(';')[1]] == 'LSTRING'
				tmp = query.clone
				tmp.delete key
				text += "<td><a href='#{filter_query(tmp)}'>#{key.split(';')[2]}</a>"
				props += [key.split(';')[2]]
			end
		end
		return text, props
	end
	
	def filter_list request
		text = "<table>\n\t<th>Filters:</th>\n"
		@order2.each do |item|
			if @schema[item].class == Array
				text += "<tr><td>" + item + "</td>"
				ar = [["*"],["*"]]
				ar[0] += @schema[item][0]
				props = []
				@schema[item][0].each do |filter|
					ar[1] += ["/#{filter_query(@query)}filter;#{item.downcase};#{filter.downcase}"]
					text += filter_query_remove(@query, filter)[0]
					props += filter_query_remove(@query, filter)[1]
				end
				props.each do |x|
					i = ar[0].index(x)
					ar[0].delete_at i
					ar[1].delete_at i
				end
				unless ar[0].length == 1
					text += "<td>" + gen_options(ar,item,nil,true) + "</td>"
				end
				text += "</tr>"
			end
			if @schema[item] == "STRING"
				text += "<tr><td>" + item + "</td>"
				ar = [["*"],["*"]]
				list = []
				props = []
				@db.values.each do |value|
					ar[0] += [value[item.downcase.to_sym]]
					ar[1] += ["/#{filter_query(@query)}filter;#{item.downcase};" + value[item.downcase.to_sym]]
					list += filter_query_remove(@query, value[item.downcase.to_sym])[0].to_a
					props += filter_query_remove(@query, value[item.downcase.to_sym])[1].to_a
				end
				text += list.uniq.to_s
				ar[0].uniq!
				ar[0].sort!
				ar[1].uniq!
				ar[1].sort!
				props.uniq!
				props.each do |x|
					i = ar[0].index(x)
					ar[0].delete_at i
					ar[1].delete_at i
				end
				unless ar[0].length == 1
					text += "<td>" + gen_options(ar,"#{item}", nil, true)+ "</td>"
				end
				text += "</tr>"
			end
			if @schema[item] == "LSTRING"
				text += "<tr><td>" + item + "</td>"
				list = []
				@db.values.each do |value|
					list += filter_query_remove(@query, value[item.downcase.to_sym])[0].to_a
				end
				list.uniq!
				text += list.to_s
				text += filter_query_remove(@query, item)[0]
				text += "</tr>"
			end
		end
		text += "</table>"
		return text
	end
	
	def do_GET(request, response)
		response.status = 200
		response['Content-Type'] = "text/html"
		response.body = start
		if request.query_string.nil? ; request.query_string = "" ; end
		@query = request.query_string.split('&')
		if request.path == '/'
			if request.query["m"] != nil
				response.body += "<span class='flash'>#{request.query["m"]}</span><br/><br/>"
			end
			response.body += filter_list request
			hash = {}
			@query.each do |key|
				if key.to_s[0..5] == 'filter'
					if hash[key.split(';')[1]] == nil
						hash[key.split(';')[1]] = [HTTPUtils.unescape(key.split(';')[2])]
					else
						hash[key.split(';')[1]] += [HTTPUtils.unescape(key.split(';')[2])]
					end
				end
			end
			response.body += list(filter(hash), request)
			response.body += "<a href='/new'>New #{@order[@id_location]}</a><br/>"
			response.body += "<a href='/newprop'>New Property</a> | <a href='/propdel'>Delete Property</a>"
		end
		if request.path[0..12] == '/propdestroy/'
			prop = request.path[13..-1]
			@schema.delete(prop)
			@db.keys.each do |key|
				@db[key].delete(prop.downcase.to_sym)
			end
			@order.delete(prop)
			
			save @db, @schema, @order, @file
			message = WEBrick::HTTPUtils.escape("Property successfully deleted")
			response.set_redirect(HTTPStatus::MovedPermanently, "/?m=#{message}")
		end
		if request.path == '/propdel'
			response.body += "<a href='/'>Return to index</a>"
			response.body += "<table>"
			response.body += header
			response.body += "<tr>"
			@order.each do |item|
				response.body += "<td><form name='#{item}' action='/propdestroy/#{item}' method='post'><input type='submit' value='Delete #{item}'  onclick='return confirmSubmit()'/></form></td>"
			end
			response.body += "</tr>"
			response.body += "</table>"
		end
		if request.path == '/newprop'
			response.body += "<a href='/'>Return to index</a>"
			response.body += "<form name='input' action='/propcreate' method='post'>"
			response.body += "<table>"
			response.body += "<tr><td>Name:</td><td><input type='text' name='name'/></td></tr>"
			response.body += "<tr><td>Type:</td><td>" + gen_options([["ID", "STRING", "LSTRING", "CHOICE"],["ID", "STRING", "LSTRING", "CHOICE"]], "type") + "</td></tr>"
			response.body += "<tr><td>Additional Data:</td><td><input type='text' name='add'></td></tr>"
			response.body += "<tr><td></td><td><input type='submit' value='Create Property'></td></tr>"
			response.body += "</table>"
			response.body += "</form>"
		end
		if request.path == '/propcreate'
			case request.query['type']
				when "STRING"
					@schema[request.query['name']]="STRING"
				when "LSTRING"
					@schema[request.query['name']]="LSTRING"
				when "ID"
					@schema[request.query['name']]="ID"
				when "CHOICE"
					@schema[request.query['name']]="STRING"
					choices = request.query['add'].split('-')
					choices2 = []
					choices.each do |x|
						choices2 += [x.downcase]
					end
					@schema[request.query['name']] = [choices, choices2]
			end
			@order += [request.query['name']]
			@db.each_key do |key|
				@db[key][request.query['name'].downcase.to_sym] = ""
			end
			save @db, @schema, @order, @file
			message = WEBrick::HTTPUtils.escape("Property Added Successfully")
			response.set_redirect(HTTPStatus::MovedPermanently, "/?m=#{message}")
		end
		if request.path == '/new'
			response.body += "<a href='/'>Return to index</a>"
			response.body += "<table>"
			response.body += "<form name='input' action='/create' method='post'>"
			@order2.each do |item|
				input = ""
				if @schema[item] == "STRING" or "LSTRING"
					input = "<input type='text' name='#{item.downcase}'/>"
				end
				if @schema[item].class == Array
					input = gen_options @schema[item], item.downcase
				end
				response.body += "<tr><td>#{item}</td><td>#{input}</td></tr>"
			end
			response.body += "<tr><td></td><td><input type='submit' value='Create New #{@order[@id_location]}'></td></tr>"
			response.body += "</form>"
			response.body += "</table>"
		end
		if request.path[0..6] == '/create'
			number = 0
			updated = ""
			if request.path[8..-1] != nil
				number = request.path[8..-1].to_i
				updated = "updated"
			else
				if !@db.keys.empty?
					number = (@db.keys.sort[-1]+1)
				else
					number = 1
				end
				updated = "added"
			end
			saving = {}
			request.query.each { |item| saving[item[0].to_sym] = item[1] }
			@db[number] = saving
			save @db, @schema, @order, @file
			message = WEBrick::HTTPUtils.escape("#{@order[@id_location]} successfully #{updated}")
			response.set_redirect(HTTPStatus::MovedPermanently, "/?m=#{message}")
		end
		begin
			if request.path[0..@order[@id_location].length+1] == "/#{@order[@id_location]}/"
				db = {}
				number = request.path.split('/')[-1].to_i
				db[number] = @db[number]
				response.body += "<a href='/'>Return to index</a>"
				response.body += list db
				response.body += "<form name='edit' action='/edit/#{number}' method='post'>"
				response.body += "<input type='submit' value='Edit #{@order[@id_location]}'></form>"
				response.body += "<form name='destroy' action='/destroy/#{number}' method='post'>"
				response.body += "<input type='submit' value='Delete #{@order[@id_location]}' onclick='return confirmSubmit()'>"
				response.body += "</form>"
			end
		rescue
		end
		if request.path[0..8] == '/destroy/'
			number = request.path[9..-1].to_i
			@db.delete(number)
			save @db, @schema, @order, @file
			message = WEBrick::HTTPUtils.escape("#{@order[@id_location]} successfully deleted")
			response.set_redirect(HTTPStatus::MovedPermanently, "/?m=#{message}")
		end
		if request.path[0..5] == '/edit/'
			number = request.path[6..-1].to_i
			response.body += "<a href='/'>Return to index</a>"
			response.body += "<form name='input' action='/create/#{number}' method='post'>"
			response.body += "<table>"
			response.body += header + "<tr><td>#{number}</td>"
			@order2.each do |item|
				input = ""
				if @schema[item] == "STRING" or @schema[item] == "LSTRING"
					input = "<input type='text' name='#{item.downcase}' value='#{@db[number][item.downcase.to_sym]}'/>"
				end
				if @schema[item].class == Array
					input = gen_options @schema[item], item.downcase, @db[number][item.downcase.to_sym]
				end
				response.body += "<td>#{input}</td>"
			end
			response.body += "</tr></table>"
			response.body += "<input type='submit' value='Save Changes'>"
			response.body += "</form>"
		end
		response.body += stop
		if request.path == '/style.css'
			response['Content-Type'] = 'text/css'
			response.body = File.new("style.css",'r').readlines.join
		end
	end
	
	# Filters a database based on the criteria in the items hash
	#
	# The items hash hash this format:
	# {property => [value_to_filter_by, value_to_filter_by]}
	def filter items, db=@db
		db2 = @db.clone
		db.each_key do |key|
			items.each_key do |key2|
				if items[key2].index(db[key][key2.to_sym]) == nil
					db2.delete key
				end
				# LSTRING support
				@schema.each_key do |key3|
					if key2 == key3.downcase and @schema[key3] == "LSTRING"
						items[key2].each do |x|
							if db[key][key2.to_sym].index(x) != nil
								db2[key] = db[key]
							end
						end
					end
				end
				
			end
		end
		return db2
	end
	
	def start head=""
		start = <<END
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
	<head>
		<title>#{@order[@id_location]} Tracker</title>
		<link rel="stylesheet" type="text/css" href="/style.css" />
		#{head}
	</head>

<body>
END
		return start
	end
	
	def stop
		stop = <<END
<script type="text/javascript">
<!--
function confirmSubmit()
{
var agree=confirm("Are you sure you want to delete this #{@order[@id_location]}?");
if (agree)
	return true ;
else
	return false ;
}
// -->
</script>

</body>
</html>
END
		return stop
	end
	
	def gen_options options, name, selected=nil, onclick=false
		change=""
		if onclick
			change=%&onChange="document.location.href=document.getElementById('#{name}').options[document.getElementById('#{name}').selectedIndex].value"&
		end
		text = "\n<select name='#{name}' id='#{name}' #{change}'>\n"
		options[0].length.times do |option|
			text += "\t<option value='#{options[1][option]}'"
			if selected == options[1][option]
				text += " selected='true'"
			end
			text += ">#{options[0][option]}</option>\n"
		end
		text += "</select>\n"
		return text
	end
	
	def header request=nil
		text = ""
		newq = @query.clone
		@order.each do |heading|
			if request != nil
				if request.query['r'] != nil or request.query['c'] != heading
					newq.each do |x|
						if x[0..1] == 'c=' or x[0..1] == 'r='
							newq.delete x
						end
					end
					uri = "/?" + newq.join('&')
					text += "<td><a href='#{uri}&c=#{HTTPUtils.escape(heading)}'>#{heading}</a></td>"
				else
					uri = "/?" + newq.join('&')
					text += "<td><a href='#{uri}&c=#{HTTPUtils.escape(heading)}&r=1'>#{heading}</a></td>"
				end
			else
				text += "<td>#{heading}</td>"
			end
		end
		return text
	end
	
	def list db, request=nil
		text = ""
		text += "<table><tr>"
		text += header request
		text += "</tr>"
		# Sort
		keys = db.keys.sort!
		if request != nil
			if request.query['c'] != nil and @schema[request.query['c']] != "ID"
				newlist = {}
				db.keys.each do |key|
					x = db[key][request.query['c'].downcase.to_sym]
					newlist[x + key.to_s] = key
				end
				keys = []
				newlist.keys.sort.each do |key|
					keys += [newlist[key]]
				end
			end
			if request.query['r'] != nil
				if request.query['r'] == '1'
					keys.reverse!
				end
			end
		end
		
		keys.each do |key|
			text += "<tr>"
			text += "<td><a href='/#{HTTPUtils.escape(@order[@id_location])}/#{key}'>#{key}</a></td>"
			@order2.each do |item|
				text += "<td><a class='intable' href='/?filter;#{item.downcase};#{db[key][item.downcase.to_sym]}'>" + db[key][item.downcase.to_sym] + "</a></td>"
			end
			text += "</tr>"
		end
		text += "</table>"
		
		return text
	end
	
	alias :do_POST :do_GET
end

if __FILE__ == $0
	# Mount servlets.
	s = HTTPServer.new(:Port => 8000, :MimeTypes =>  WEBrick::HTTPUtils::DefaultMimeTypes, :DocumentRoot => Dir.pwd)
	s.mount('/', CustomServlet)

	# Trap signals so as to shutdown cleanly.
	['TERM', 'INT'].each do |signal|
		trap(signal) {s.shutdown}
	end

	# Start the server and block on input
	s.start
end
