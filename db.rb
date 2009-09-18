require 'yaml'

def load_tdb3 file
	input = File.new file, 'r'
	lines = input.read.split('||')
	# If it is a blank file
	if lines.empty? ; return {}, {}, [] ; end
	db = {}
	schema = lines[0].split('|')
	schema2 = {}
	order = []
	# Load schema
	schema.each do |property|
			items = property.split('^')
			items[0].strip!
			items[1].strip!
			order += [items[0]]
			schema2[items[0]] = items[1]
	end
	schema2.each_key do |key|
		if schema2[key][0..5] == "CHOICE"
			schema2[key] = schema2[key][7..-1].split('-')
		end
	end
	# Load database items
	lines[1..-1].each do |line|
		line.chomp!
		column = line.split('|')
		column.each { |x| x.strip! }
		id_location = 0
		schema2.each { |key, value| if value == "ID" ; id_location = order.index(key) ; end }
		order2 = order.clone
		order2.delete_at(id_location)
		hash = {}
		order2.each do |x|
			hash[x] = column[order.index(x)]
		end
		if column[id_location].to_i == 0
			break
		end
		db[column[id_location].to_i] = hash
	end
	input.close
	return db, schema2, order
end

def save_tdb3 db, schema, order, file
	text = ""
	# Create header
	order.length.times do |x|
		text += order[x].to_s + " ^ "
		if schema[order[x]].class == Array
			text += "CHOICE "
			schema[order[x]].each do |ar|
				ar.each do |item|
					text += item + '-'
				end
			end
			text.chop!
		else
			text += schema[order[x]].to_s
		end
		text += " | "
	end
	text.chop!
	text.chop!
	text += "||\n"
	# Save data
	id_location = 0
	schema.each { |key, value| if value == "ID" ; id_location = order.index(key) ; end }
	# Find the longest entry (so the output looks nice)
	length = []
	order.each do |x|
		top = 0
		db.each do |key, value|
			unless id_location == order.index(x)
				if value[x].length > top ; top = value[x].length ; end
			else
				if key.to_s.length > top ; top = key.to_s.length ; end
			end
		end
		length[order.index(x)] = top
	end
	# Actually go through and save the data
	db.keys.sort.each do |key|
		order.length.times do |x|
			if id_location == x
				space = length[x] - key.to_s.length
				sp = ' ' * space
				text << key.to_s + sp + ' |' 
			else
				space = length[x] - db[key][order[x]].length
				sp = ' ' * space
				text << ' ' + db[key][order[x]] + sp + ' |' 
			end
		end
		text += "|\n"
	end
	unless text.empty?
		output = File.new file, 'w'
		output.print text
		output.close
	else
		puts "***************\nFILE SAVE ERROR\n***************"
	end
end

def save_yaml db, schema, file
	File.open(file, 'w') do |out|
		YAML.dump([db, schema, order],out)
	end
end

def load_yaml file
	File.open( file ) { |yf| YAML::load( yf ) }
end

def save_db db, schema, order, file
	if file[-3..-1] == 'yml' or file[-4..-1] == 'yaml'
		save_yaml db, schema, order, file
	end
	if file[-3..-1] == 'tdb'
		save_tdb3 db, schema, order, file
	end
end

def load_db file
	if !File.exists?(file)
		a = File.new file, 'w'
		a.close
	end
	if file[-3..-1] == 'yml' or file[-4..-1] == 'yaml'
		return load_yaml(file)
	end
	if file[-3..-1] == 'tdb'
		return load_tdb3(file)
	end
end

if __FILE__ == $0
	#db, schema, order = load "EXAMPLE2.tdb"
	a = load_db("EX3-OUT.tdb")
	a.each do |x|
		p x
		puts "\n\n"
	end
	save_db a[0], a[1], a[2], "EX3-OUT.tdb"
	#save db, schema, order, "EX2-OUT.tdb"
end
