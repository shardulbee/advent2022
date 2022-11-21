require_relative './input_reader'
require 'set'
require 'pp'

class Node
  attr_reader :metadata, :children

  def initialize(children: [], metadata: [])
    @children = children
    @metadata = metadata
  end

  def value
    return metadata.sum if children.empty?

    metadata.inject(0) do |acc, index|
      next acc if index == 0

      child_value = children[index - 1]&.value || 0
      acc + child_value
    end
  end
end

def process_node(input, i)
  num_children = input[i]
  num_metadata = input[i + 1]

  if num_children == 0
    metadata_start = i + 2
    metadata_end = metadata_start + num_metadata
    metadata = input[metadata_start...metadata_end]
    return [metadata_end, Node.new(children: [], metadata: metadata)]
  end

  idx = i + 2
  children = num_children.times.map do
    idx, child = process_node(input, idx)
    child
  end

  metadata_end = idx + num_metadata

  metadata = input[idx...(metadata_end)]
  return [metadata_end, Node.new(children: children, metadata: metadata)]
end

def compute_part_one(input)
  _, root = process_node(input, 0)

  to_visit = [root]
  sum = 0
  while !to_visit.empty?
    visit = to_visit.shift
    sum += visit.metadata.sum
    to_visit.prepend(*visit.children)
  end

  sum
end

def compute_part_two(input)
  _, root = process_node(input, 0)

  root.value
end

reader = InputReader.new(8)

TEST_INPUT = <<~INPUT.chomp.split(" ").map(&:to_i)
2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2
INPUT

puts "part 1 - test data: #{compute_part_one(TEST_INPUT)}"
puts "part 1: #{compute_part_one(reader.as_ints)}"
puts "part 2 - test data: #{compute_part_two(TEST_INPUT)}"
puts "part 2: #{compute_part_two(reader.as_ints)}"
