require 'benchmark'
require 'db'

puts Benchmark.measure { load "STRESS.tdb" }
