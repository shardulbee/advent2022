require_relative './input_reader'
require 'benchmark'

def compute_part_one(reader)
  num_with_two = 0
  num_with_three = 0
  reader.as_lines.each do |line|
    counts = line.split("").group_by{ _1 }.map { _2.length }
    num_with_two += 1 if counts.any? { _1 == 2 }
    num_with_three += 1 if counts.any? { _1 == 3 }
  end

  return num_with_two * num_with_three
end

def compute_part_two(reader)
  lines = reader.as_lines
  max_length = lines.first.length

  (0...max_length).each do |index_to_remove|
    seen = {}
    spliced_lines = lines.map do |line|
      line = line[0...index_to_remove] + line[index_to_remove + 1..]
    end

    spliced_lines.each do |line|
      return line if seen.include?(line)
      seen[line] = true
    end
  end
  raise
end

def compute_part_two_slower(reader)
  lines = reader.as_lines
  max_length = lines.first.length

  max_length

  (0...max_length).each do |index_to_remove|
    spliced_lines = lines.map do |line|
      line = line[0...index_to_remove] + line[index_to_remove + 1..]
    end

    spliced_lines.combination(2).each do |s1, s2|
      return s1 if s1 == s2
    end
  end
end


reader = InputReader.new(2)

# puts "part 1: #{compute_part_one(reader)}"
# puts "part 2: #{compute_part_two(reader)}"
# puts "part 2 slower: #{compute_part_two_slower(reader)}"

require 'benchmark/ips'

Benchmark.ips do |x|
  x.report("part 2 - fast") { compute_part_two(reader) }
  x.report("part 2 - slow") { compute_part_two_slower(reader) }

  x.compare!
end



