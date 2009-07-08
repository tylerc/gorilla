File.open("STRESS.tdb", 'w') do |f|
	f.puts "Bug ^ ID | Description ^ LSTRING | Type ^ CHOICE Defect-Blocker-Enhancement-Feature Request | Status ^ CHOICE Open-Fixed | Priority ^ CHOICE Low-Medium-High | Milestone ^ STRING"
	type = ['Defect', 'Blocker', 'Enhancement', 'Feature Request']
	status = ['Open', 'Fixed']
	priority = ['Low', 'Medium', 'High']
	1_000.times do |num|
		# Build stress line
		line = [type[rand(4)], status[rand(2)], priority[rand(3)], rand(100).to_f.to_s] 
		f.puts "#{num+1} | test | #{line.join(' | ')}"
	end
end
puts "Done Writing..."
