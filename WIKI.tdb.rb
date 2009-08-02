@mode = :div
@inline_links = false

if cur == '/index' or cur == ''
	@db.each do |pair|
		@db[pair[0]]['Title'] = "<a href=\"/view/#{pair[0]}\">" + pair[1]['Title'] + "</a>"
	end
end
