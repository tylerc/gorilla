Dir.chdir File.expand_path(File.dirname(__FILE__))

require 'benchmark'
require '../db'

# Creates a database for stress testing
#
# Change the number in the '.times' loop to change the
# number of entries in the database.
db = {}
schema = {"Status"=>["Open", "Fixed"], "Milestone"=>"STRING", "Priority"=>["Low", "Medium", "High"], "Description"=>"LSTRING", "Bug"=>"ID", "Type"=>["Defect", "Blocker", "Enhancement", "Feature Request"]}
order = ["Bug", "Description", "Type", "Status", "Priority", "Milestone"]
data = {"Description" => ["test"], "Type" => ['Defect', 'Blocker', 'Enhancement', 'Feature Request'], "Status" => ['Open', 'Fixed'], "Priority" => ['Low', 'Medium', 'High'], "Milestone" => ["1.1"]}
1_000.times do |num|
	order[1..-1].each do |item|
		db[num+1] = {} if db[num+1].nil?
		db[num+1][item] = data[item][rand(data[item].length)]
	end
end
puts "Done creating"
puts Benchmark.measure { save_db db, schema, order, "STRESS.tdb" }
puts "Done Writing..."
