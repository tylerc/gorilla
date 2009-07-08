require 'yaml'

def load_db2 file
	input = File.new file, "r"
	lines = input.readlines
	# If its a blank start file
	if lines.empty? ; return {}, {}, [] ; end
	db = {}
	schema = lines[0].split('|')
	schema2 = {}
	order = []
	schema.each do |x|
		y = x.split('^')
		y[0].strip!
		y[1].strip!
		order += [y[0]]
		schema2[y[0]] = y[1]
	end
	schema2.each_key do |key|
		if schema2[key][0..5] == "CHOICE"
			choices = schema2[key][7..-1].split('-')
			choices2 = []
			choices.each do |x|
				choices2 += [x.downcase]
			end
			schema2[key] = [choices, choices2]
		end
	end
	#p schema2
	#p order
	lines[1..-1].each do |line|
		line.chomp!
		column = line.split('|')
		column.each { |x| x.strip! }
		id_location = 0
		schema2.each { |pair| if pair[1] == "ID" ; id_location = order.index(pair[0]) ; end }
		order2 = order.clone
		order2.delete_at(id_location)
		hash = {}
		order2.each do |x|
			hash[x.downcase.to_sym] = column[order.index(x)]
		end
		if column[id_location].to_i == 0
			break
		end
		db[column[id_location].to_i] = hash
	end
	input.close
	#p db
	return db, schema2, order
end

def save_db2 db, schema, order, file
	# Save Schema (first line)
	output = File.new file, 'w'
	text = ""
	order.length.times do |x|
		text += order[x].to_s + " ^ "
		if schema[order[x]].class == Array
			text += "CHOICE "
			schema[order[x]][0].each do |ar|
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
	text += "\n"
	# Save data
	id_location = 0
	schema.each { |pair| if pair[1] == "ID" ; id_location = order.index(pair[0]) ; end }
	order2 = order.clone
	order2.delete_at(id_location)
	
	db.keys.sort.each do |key|
		text += key.to_s
		order2.length.times do |x|
			text += ' | ' + db[key][order2[x].downcase.to_sym]
		end
		text += "\n"
	end
	output.print text
	output.close
end

def save_yaml db, schema, file
	File.open(file, 'w') do |out|
		YAML.dump([db, schema, order],out)
	end
end

def load_yaml file
	File.open( file ) { |yf| YAML::load( yf ) }
end

def save db, schema, order, file
	if file[-3..-1] == 'yml' or file[-4..-1] == 'yaml'
		save_yaml db, schema, order, file
	end
	if file[-3..-1] == 'tdb'
		save_db2 db, schema, order, file
	end
end

def load file
	if !File.exists?(file)
			a = File.new file, 'w'
			a.close
	end
	if file[-3..-1] == 'yml' or file[-4..-1] == 'yaml'
		return load_yaml(file)
	end
	if file[-3..-1] == 'tdb'
		return load_db2(file)
	end
end

if __FILE__ == $0
	db, schema, order = load "EXAMPLE2.tdb"
	save db, schema, order, "EX2-OUT.tdb"
	#p schema
	#puts '-----'
	#p db
	#db = load_db "EXAMPLE"
	#save_db db, "EX-OUT"
end
