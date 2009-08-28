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
	@db = @db_final if @db.empty? # Show all bugs if there are no open ones
end

# How to dynamically add a column, an example:
#@db.each do |pair|
#	@db[pair[0]]["Length"] = @db[pair[0]]["Description"].length
#end
#@order += ["Length"]
#@order2 += ["Length"]
