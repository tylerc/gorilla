# Benchmarks database parsing (see README for benchmark results)

require 'benchmark'
require 'db'

puts Benchmark.measure { load_db "STRESS.tdb" }
