require_relative 'input_reader'

def test_input
  raw = <<-INPUT
1000
2000
3000

4000

5000
6000

7000
8000
9000

10000
  INPUT

  raw.split("\n\n").map { _1.split("\n").map(&:to_i) }
end

def prod_input
  InputReader
    .new(1)
    .as_line
    .split("\n\n")
    .map { _1.split("\n").map(&:to_i) }
end

def compute_part_one(input)
  max_elem = input
    .each
    .with_index(1)
    .max_by { |items, _| items.sum }
  max_elem[0].sum
end

def compute_part_two(input)
  input.map(&:sum).sort[-3..].sum
end

puts "part 1 - test: #{compute_part_one(test_input)}"
puts "part 1 - prod: #{compute_part_one(prod_input)}"
puts "part 2 - test: #{compute_part_two(test_input)}"
puts "part 2 - test: #{compute_part_two(prod_input)}"
