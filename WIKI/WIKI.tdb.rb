request.query["mode"] = "div" # Set mode to div, instead of table, the default
request.query["inline_links"] = "false" # Don't give each attribute a link to its filter

if cur == '/index' or cur == '' # If we are in the index listing
	request.query["r"] = "1" # Reverse the order of the page listings
	@db.each do |key, value| # Make each title a link to its view page
		@db[key]['Title'] = "<a href=\"/view/#{key}\">" + value['Title'] + "</a>"
	end
end
