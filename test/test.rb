# Benchmarks database parsing (see README for benchmark results)
Dir.chdir File.expand_path(File.dirname(__FILE__))

require 'benchmark'
require '../db'

puts Benchmark.measure { load_db Dir.pwd + "/STRESS.tdb" }
