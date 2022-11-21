require_relative './input_reader'

LINE_RE = /(-*\d+)/

class Point
  attr_accessor :initial, :velocity

  def initialize(initial, velocity)
    @initial= initial
    @velocity = velocity
  end

  def advance
    @initial = [
      initial[0] + velocity[0],
      initial[1] + velocity[1]
    ]
  end
end

class Sky
  BOUNDARY_PADDING = 0.2

  attr_accessor :points

  def initialize(points)
    @points = points
    @counter = 0
  end

  def advance
    points.each(&:advance)
    @counter += 1
  end

  def too_far?
    xs = points.map { _1.initial[0] }
    ys = points.map { _1.initial[1] }

    xs.max - xs.min > 280 || ys.max - ys.min > 100
  end

  def print_sky
    if too_far?
      return
    end

    xs = points.map { _1.initial[0] }
    ys = points.map { _1.initial[1] }

    x_shift = 0 - xs.min
    y_shift = 0 - ys.min

    point_h = points.map do |point|
      x, y = point.initial
      [[x, y], true]
    end.to_h

    puts "Showing sky after #{@counter} seconds"
    (0..ys.max + y_shift).each do |y|
      (0..xs.max + x_shift).each do |x|
        if point_h[[x - x_shift, y - y_shift]]
          print "#"
        else
          print "."
        end
      end
      print "\n"
    end

    puts
  end
end

def parse_raw(line)
  matches = line.scan(LINE_RE).flat_map { _1 }
  raise unless matches.length == 4

  initial = matches[0..1].map(&:to_i)
  velocity = matches[2..3].map(&:to_i)

  return Point.new(initial, velocity)
end

def compute_part_one(raw)
  points = raw.map { parse_raw(_1) }
  sky = Sky.new(points)

  while sky.too_far?
    sky.advance
  end

  while true do
    puts "Advance? y/n"
    prompt = gets.chomp
    case prompt
    when "y"
      puts
      sky.advance
      sky.print_sky
    when "n"
      break
    else
      puts "Invalid input. Please provide y/n."
    end
  end
end

def compute_part_two(raw)
end

reader = InputReader.new(10)

TEST_DATA = <<~INPUT.split("\n").map(&:chomp)
position=< 9,  1> velocity=< 0,  2>
position=< 7,  0> velocity=<-1,  0>
position=< 3, -2> velocity=<-1,  1>
position=< 6, 10> velocity=<-2, -1>
position=< 2, -4> velocity=< 2,  2>
position=<-6, 10> velocity=< 2, -2>
position=< 1,  8> velocity=< 1, -1>
position=< 1,  7> velocity=< 1,  0>
position=<-3, 11> velocity=< 1, -2>
position=< 7,  6> velocity=<-1, -1>
position=<-2,  3> velocity=< 1,  0>
position=<-4,  3> velocity=< 2,  0>
position=<10, -3> velocity=<-1,  1>
position=< 5, 11> velocity=< 1, -2>
position=< 4,  7> velocity=< 0, -1>
position=< 8, -2> velocity=< 0,  1>
position=<15,  0> velocity=<-2,  0>
position=< 1,  6> velocity=< 1,  0>
position=< 8,  9> velocity=< 0, -1>
position=< 3,  3> velocity=<-1,  1>
position=< 0,  5> velocity=< 0, -1>
position=<-2,  2> velocity=< 2,  0>
position=< 5, -2> velocity=< 1,  2>
position=< 1,  4> velocity=< 2,  1>
position=<-2,  7> velocity=< 2, -2>
position=< 3,  6> velocity=<-1, -1>
position=< 5,  0> velocity=< 1,  0>
position=<-6,  0> velocity=< 2,  0>
position=< 5,  9> velocity=< 1, -2>
position=<14,  7> velocity=<-2,  0>
position=<-3,  6> velocity=< 2, -1>
INPUT

# puts "part 1 - test data: #{compute_part_one(TEST_DATA)}"
puts "part 1: #{compute_part_one(reader.as_lines)}"
# puts "part 2: #{compute_part_two}"
