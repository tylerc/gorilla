request.query["mode"] = "div" # Set mode to div, instead of table, the default
request.query["inline_links"] = "false" # Don't give each attribute a link to its filter

if cur == '/index' or cur == '' # If we are in the index listing
	request.query["r"] = "1" # Reverse the order of the page listings
	@db.each do |pair| # Make each title a link to its view page
		@db[pair[0]]['Title'] = "<a href=\"/view/#{pair[0]}\">" + pair[1]['Title'] + "</a>"
	end
end
