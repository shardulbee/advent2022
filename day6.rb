require_relative './input_reader'

COORDINATE_RE = /^(\d+), (\d+)/

def compute_part_one(coordinates)
  xs = coordinates.map { _1[0] }.sort
  ys = coordinates.map { _1[1] }.sort

  finites = coordinates.select do |x, y|
    x > xs.min && x < xs.max && y > ys.min && y < ys.max
  end

  closest = {}
  (xs.min..xs.max).each do |x|
    (ys.min..ys.max).each do |y|
      closest[[x, y]] = compute_closest(x, y, coordinates)
    end
  end

  finites.map do |finite_coord|
    closest.values.count { _1 == finite_coord }
  end.max
end

def compute_closest(x, y, coords)
  coords.min_by do |coord|
    (coord[0] - x).abs + (coord[1] - y).abs
  end
end

def compute_part_two(coordinates)
  xs = coordinates.map { _1[0] }.sort
  ys = coordinates.map { _1[1] }.sort

  area = 0
  (xs.min..xs.max).each do |x|
    (ys.min..ys.max).each do |y|
      dist_to_all = coordinates.sum { (_1[0] - x).abs + (_1[1]- y).abs }
      if dist_to_all < 10_000
        area += 1
      end
    end
  end
  area
end

def parse_lines(lines)
  lines.map do |line|
    matches = line.match(COORDINATE_RE)
    raise if matches.nil?

    [matches[1].to_i, matches[2].to_i]
  end
end

reader = InputReader.new(6)

test_input = <<~INPUT
1, 1
1, 6
8, 3
3, 4
5, 5
8, 9
INPUT

# puts "part 1 - test data: #{compute_part_one(parse_lines(test_input.split("\n")))}"
# puts "part 1: #{compute_part_one(parse_lines(reader.as_lines))}"
puts "part 2: #{compute_part_two(parse_lines(reader.as_lines))}"
