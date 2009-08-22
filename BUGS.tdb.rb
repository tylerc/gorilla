# Custom code for BUGS.tdb

# Sets the default filter.
# Is separated into a function, because it main be integrated
# into a helper file.
def default_filter filter, request
	@db = filter(filter) unless !find_filters(request).empty?
end

# If we are in the index controller
if cur == '' or cur == '/index'
	default_filter({"Status" => ["Open"]}, request)
end
