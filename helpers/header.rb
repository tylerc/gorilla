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

def build_query hash
	text = "?"
	hash.each do |pair|
		unless pair[0] == 'm'
		  text += pair[0] + '=' + pair[1] + '&'
		end
	end
	return text
end

def list(db, request)
	text = ""
	keys = db.keys.sort
	if request.query['s'] != nil and @schema[request.query['s']] != "ID"
		newlist = {}
		db.keys.each do |key|
			x = db[key][request.query['s']]
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
	keys.each do |key|
		link = ""
		link = "<a href=\"/view/#{key}\">#{key}</a>" if @inline_links
		link = "#{key}" if !@inline_links
		text += "<tr>" if @mode == :table
		text += "<td>#{link}</td>" if @mode == :table
		text += "<div class='wrapper'><div class='#{@order[@id_location]}'>#{link}</div>" if @mode == :div
		@order2.each do |item|
			link = "<a class='intable' href='/?filter#{item}#{@db[key][item]}'>#{ @db[key][item] }</a>" if @inline_links
			link = "#{ @db[key][item] }" if !@inline_links
			text += "<td>#{link}</td>" if @mode == :table
			text += "<div class='#{item}'>#{link}</div>" if @mode == :div
		end
		text += "</div>" if @mode == :div
		text += "</tr>" if @mode == :table
	end
	return text
end
