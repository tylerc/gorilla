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
	hash.each do |key, value|
		value = "" if value == nil
		# This moves all LSTRING filters to the proper place
		# i.e. filterDescription=e becomes filterDescriptione
		if key[0..5] == 'filter' and !value.empty?
			@schema.each_key do |key2|
				if key[6..-1].index(key2) == 0
					key += value
					value = ""
				end
			end
		end
		unless key == 'm'
			text += key + '=' + value + '&'
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
		link = "<a href=\"/view/#{key}\">#{key}</a>" if request.query["inline_links"] == "true"
		link = "#{key}" if request.query["inline_links"] == "false"
		text << "<tr>" if request.query["mode"] == "table"
		text << "<td>#{link}</td>" if request.query["mode"] == "table"
		text << "<div class='wrapper'><div class='#{@order[@id_location]}'>#{link}</div>" if request.query["mode"] == "div"
		@order2.each do |item|
			link = "<a class='intable' href='/?filter#{item}#{db[key][item]}'>#{ db[key][item] }</a>" if request.query["inline_links"] == "true"
			link = "#{ db[key][item] }" if request.query["inline_links"] == "false"
			text << "<td>#{link}</td>" if request.query["mode"] == "table"
			text << "<div class='#{item}'>#{link}</div>" if request.query["mode"] == "div"
		end
		text << "</div>" if request.query["mode"] == "div"
		text << "</tr>" if request.query["mode"] == "table"
	end
	return text
end
