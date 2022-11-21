require_relative './input_reader'

def compute_part_one(reader)
  reader.as_lines.map(&:to_i).sum
end

def compute_part_two(reader)
  acc = {}
  frequency = 0
  found = false

  while !found
    reader.as_lines.each do |change|
      frequency += change.to_i

      if acc.include?(frequency)
        return frequency
      end

      acc[frequency] = true
    end
  end

  return -1
end

reader = InputReader.new(1)

puts "Part 1: #{compute_part_one(reader)}"
puts "Part 2: #{compute_part_two(reader)}"
