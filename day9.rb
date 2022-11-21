require_relative './input_reader'

def compute_part_one(num_players, last_marble)
  scores = [0] * num_players

  current_player = 1
  current_marble = 1
  current_marble_index = 0
  marbles = [0]
  while current_marble != last_marble + 1
    if current_marble == 46
    end
    if current_marble % 23 == 0
      remove_index = (current_marble_index - 7) % marbles.length
      scores[current_player] += current_marble
      scores[current_player] += marbles.delete_at(remove_index)
      current_marble_index = remove_index
    else
      insert_index = (current_marble_index + 2) % marbles.length
      if insert_index == 0
        marbles << current_marble
        insert_index = marbles.length - 1
      else
        marbles.insert(insert_index, current_marble)
      end
      current_marble_index = insert_index
    end

    # puts "[#{current_player}] #{marbles}"
    current_player = (current_player + 1) % num_players
    current_marble += 1
  end

  scores.max
end

class Node
  attr_writer :next_node, :prev_node
  attr_reader :val

  def initialize(next_node, prev_node, val)
    @next_node = next_node
    @prev_node = prev_node
    @val = val
  end

  def next_node
    if @next_node.nil?
      self
    else
      @next_node
    end
  end

  def prev_node
    if @prev_node.nil?
      self
    else
      @prev_node
    end
  end
end

def compute_part_two(num_players, last_marble)
  scores = [0] * num_players

  current_marble = Node.new(nil, nil, 0)
  next_player = 1
  next_marble_num = 1

  while next_marble_num <= last_marble
    if next_marble_num % 23 == 0
      scores[next_player] += next_marble_num
      7.times { current_marble = current_marble.prev_node }
      scores[next_player] += current_marble.val

      plus_one = current_marble.next_node
      minus_one = current_marble.prev_node
      plus_one.prev_node = minus_one
      minus_one.next_node = plus_one
      current_marble = plus_one
    else
      plus_one = current_marble.next_node
      plus_two = plus_one.next_node

      new_node = Node.new(
        plus_two,
        plus_one,
        next_marble_num
      )
      plus_one.next_node = new_node
      plus_two.prev_node = new_node
      current_marble = new_node
    end

    next_player = (next_player + 1) % num_players
    next_marble_num += 1
  end

  scores.max

end

raise "Failed testcase for part 1" unless compute_part_two(9, 25) == 32
raise "Failed testcase for part 1" unless compute_part_two(10, 1618) == 8317
raise "Failed testcase for part 1" unless compute_part_two(13, 7999) == 146373
raise "Failed testcase for part 1" unless compute_part_two(17, 1104) == 2764
raise "Failed testcase for part 1" unless compute_part_two(21, 6111) == 54718
raise "Failed testcase for part 1" unless compute_part_two(30, 5807) == 37305

# puts "part 1: #{compute_part_two(493, 71863)}"
puts "part 2: #{compute_part_two(493, 71863 * 100)}"

require 'benchmark/ips'

Benchmark.ips do |x|
  x.time = 20
  x.warmup = 5

  x.report("slow solution") do
    compute_part_one(493, 71863)
    compute_part_one(9, 25)
    compute_part_one(10, 1618)
    compute_part_one(13, 7999)
    compute_part_one(17, 1104)
    compute_part_one(21, 6111)
    compute_part_one(30, 5807)
  end

  x.report("fast solution") do
    compute_part_two(493, 71863)
    compute_part_two(9, 25)
    compute_part_two(10, 1618)
    compute_part_two(13, 7999)
    compute_part_two(17, 1104)
    compute_part_two(21, 6111)
    compute_part_two(30, 5807)
  end

  x.compare!
end
