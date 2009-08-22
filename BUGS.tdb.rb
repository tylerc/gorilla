# Custom code for BUGS.tdb

def default_filter filter, request
	@db = filter(filter) unless !find_filters(request).empty?
end

if cur == '' or cur == '/index'
	default_filter({"Status" => ["Open"]}, request)
end
