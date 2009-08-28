@w = false
@file = 'BUGS/BUGS.tdb'
@port = 8000
ARGV.each do |i|
	if i == '-f'
		@file = ARGV[ARGV.index(i)+1]
	end
	if i == '-p'
		@port = ARGV[ARGV.index(i)+1]
	end
	if i == '-w'
		@w = true
	end
end
begin
	raise LoadError unless @w == false
	require 'rubygems'
	require 'mongrel'
	require 'erb'
	require 'db'
	require 'ostruct'
	require 'gorilla_mongrel'
rescue LoadError
	require 'webrick'
	require 'erb'
	require 'db'
	require 'gorilla_webrick'
end
