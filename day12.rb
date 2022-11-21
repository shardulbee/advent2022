require_relative './input_reader'

def compute_part_one(plants)
  score = plants.score
  300.times do |i|
    plants.advance_generation
    new_score = plants.score

    # puts "old score: #{score}, new score: #{new_score}, delta: #{new_score - score}"
    score = new_score
  end

  score
end

class Plants
  attr_accessor :state, :rules, :start_index

  NUM_PADDING = 2

  def initialize(initial, rules)
    @state = "." * 100 + initial + "." * 100
    @rules = rules
    @start_index = -100
  end

  def advance_generation
    new_state = '..'

    (2..state.length - 2).each do |i|
      segment = state[i-2..i+2]

      matching_rules = rules.select { _1.match?(segment) }

      if matching_rules.length > 1
        raise "Found more than 1 matching rule for segment=#{segment}"
      elsif matching_rules.length == 0
        new_state << segment[2]
      else
        new_state << matching_rules.first.new_plant_state(segment)
      end
    end

    new_state << ".."

    @state = new_state
  end

  def score
    state.chars.each.with_index(start_index).sum do |char, index|
      next 0 unless char == '#'
      index
    end
  end
end

def compute_part_two(plants)

  stabilize_index = 0
  prev_score = plants.score
  prev_delta = -1
  total_num_iterations = 50000000000

  until (plants.score - prev_score) == prev_delta
    prev_delta = plants.score - prev_score
    prev_score = plants.score
    plants.advance_generation
    stabilize_index += 1
  end

  puts "stablized at iteration #{stabilize_index} with delta: #{prev_delta}"

  prev_score + (total_num_iterations - stabilize_index) * prev_delta

  # initial = 145
  # iter 1, index 0, score 147
  # iter 2, index 1, score 148
  # iter 3, index 2, score 150
  # iter 4, index 3, score 152 ----- stab
  # iter 5, index 4, score 154
  # iter 6, index 5, score 156
  # iter 7, index 6, score 158
  # iter 8, index 7, score 160
  # iter 9, index 8, score 162
  # iter 10, index 9, score 164
end

class Rule
  attr_accessor :lhs, :rhs

  def initialize(lhs, rhs)
    @lhs = lhs
    @rhs = rhs
  end

  def match?(current_segment)
    lhs == current_segment
  end

  def new_plant_state(current_segment)
    return current_segment[2] unless match?(current_segment)
    rhs
  end
end

def parse_raw(lines)
  initial = lines[0].match(/([\.#]+)/)[1]
  rules = lines[2..].map do |raw_rule|
    lhs, rhs = raw_rule.scan(/[\.#]+/)

    Rule.new(lhs, rhs)
  end

  Plants.new(initial, rules)
end

def test_input
  input = <<~INPUT.split("\n").map(&:chomp)
initial state: #..#.#..##......###...###

...## => #
..#.. => #
.#... => #
.#.#. => #
.#.## => #
.##.. => #
.#### => #
#.#.# => #
#.### => #
##.#. => #
##.## => #
###.. => #
###.# => #
####. => #
  INPUT
  parse_raw(input)
end

def prod_input
  reader = InputReader.new(12)
  parse_raw(reader.as_lines)
end

puts "part 1 - #{compute_part_one(prod_input)}"
puts "part 2 - #{compute_part_two(prod_input)}"
