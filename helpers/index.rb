def find_filters request
	filters = {}
	request.query.each_key do |key|
		if key[0..5] == 'filter'
			@order.each do |item|
				if key[6..6+item.length] == item
					if filters[item] == nil
						filters[item] = [request.query[key]]
					else
						filters[item] += [request.query[key]]
					end
				end
			end
			@order.each do |item|
				unless @schema[item] == "LSTRING"
					if key[6..5+item.length] == item
						if filters[item] == nil
							filters[item] = [key[6+item.length..-1]]
						else
							filters[item] += [key[6+item.length..-1]]
						end
					end
				end
			end
		end
	end
	return filters
end

def filter items, db=@db
	db2 = db.clone
	db.each_key do |key|
		items.each_key do |key2|
			if items[key2].index(db[key][key2]) == nil
				unless @schema[key2] == "LSTRING"
					db2.delete key
				else
					fail = true
					items[key2].each do |item|
						if db[key][key2].downcase.index(item.downcase) != nil
							fail = false
						end
					end
					if fail
						db2.delete key
					end
				end
			end
		end
	end
	return db2
end

def filter_list request
	text = ""
	@order2.each do |item|
		text += "<tr>"
		if @schema[item].class == Array
			links = ['*']
			labels = ['*'] + @schema[item]
			remove = []
			filters = find_filters(request)
			@schema[item].each do |x|
				links += [build_query(request.query) + "filter#{item}#{x}"]
				unless filters[item].nil?
					if filters[item].index(x) != nil
						remove += [x]
						links.delete_at labels.index(x)
						labels.delete_at labels.index(x)
					end
				end
			end
			text += "<td>#{item}</td>"
			remove.each do |link|
				text += "<td><a href='#{query = request.query.clone ; query.delete "filter#{item}#{link}" ; build_query(query)}'>#{link}</a>"
			end
			unless links.length == 1
				text += "<td>#{gen_options([labels,links], item, nil, true)}</td>"
			end
		end
		if @schema[item] == "STRING"
			strings = ['*']
			links = ['*']
			@db_final.each_value do |value|
				strings += [value[item]]
				links += [build_query(request.query) + "filter#{item}#{value[item]}"]
			end
			strings.uniq!
			strings.sort!
			links.uniq!
			links.sort!
			text += "<td>#{item}</td>"
			filters = find_filters(request)
			unless filters[item].nil?
				filters[item].each do |x|
					text += "<td><a href='#{query = request.query.clone ; query.delete "filter#{item}#{x}" ; build_query(query)}'>#{x}</a></td>"
				end
			end
			unless links.length == 1
				text += "<td>#{gen_options([strings,links], item, nil, true)}</td>"
			end
		end
		if @schema[item] == "LSTRING"
			text += "<form method='get' action ='/'>"
			text += "<td>#{item}</td>"
			filters = find_filters(request)
			unless filters[item].nil?
				filters[item].each do |x|
					text += "<td><a href='#{query = request.query.clone ; query.delete "filter#{item}" ; build_query(query)}'>#{x}</a></td>"
				end
			end
			text += "<td><input type='text' name='filter#{item}'/><input type='submit' value='Search' /></td>"
			text += "</form>"
		end
		text += "</tr>"
	end
	return text
end
