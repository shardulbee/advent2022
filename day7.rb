require_relative './input_reader'
require 'set'
require 'pp'

LINE_REGEX = /^Step ([A-Z]) must be finished before step ([A-Z]) can begin.$/
BASE_STEP_RUNTIME = 60
BYTE_OFFSET = 64
NUM_WORKERS = 5

def parse_raw_edge(raw)
  matches = raw.match(LINE_REGEX)
  raise if matches.nil?

  [matches[1], matches[2]]
end

def compute_part_one(input)
  edges = input.map { parse_raw_edge(_1) }
  adjacency = {}
  reverse_adjacency = {}
  edges.each do |v1, v2|
    if adjacency.include?(v1)
      adjacency[v1].push(v2)
    else
      adjacency[v1] = [v2]
    end

    if reverse_adjacency.include?(v2)
      reverse_adjacency[v2].push(v1)
    else
      reverse_adjacency[v2] = [v1]
    end
  end

  roots = Set.new(edges.flat_map { _1 })
  edges.each do |v1, v2|
    roots.delete(v2)
  end

  to_visit = roots.sort
  visited = []
  while !to_visit.empty?
    visiting = to_visit.shift
    visited << visiting
    neighbours = adjacency[visiting] || []
    neighbours.each do |neighbour|
      reverse = reverse_adjacency[neighbour]
      reverse.delete(visiting)
      if reverse.empty?
        to_visit << neighbour
      end
    end
    to_visit.sort!
  end

  visited.join
end

def step_to_runtime(step, base_step_runtime)
  base_step_runtime + step.bytes.first - BYTE_OFFSET
end

def compute_part_two_faster(raw, num_workers, base_step_runtime)
  edges = raw.map { parse_raw_edge(_1) }
  free_workers = num_workers
  busy_workers = []

  adjacency = {}
  reverse_adjacency = {}
  edges.each do |v1, v2|
    if adjacency.include?(v1)
      adjacency[v1].push(v2)
    else
      adjacency[v1] = [v2]
    end

    if reverse_adjacency.include?(v2)
      reverse_adjacency[v2].push(v1)
    else
      reverse_adjacency[v2] = [v1]
    end
  end

  roots = Set.new(edges.flat_map { _1 })
  edges.each do |v1, v2|
    roots.delete(v2)
  end

  to_visit = roots.sort
  visited = []
  i = 0
  while !to_visit.empty? || !busy_workers.empty?
    # puts "workers at beginning of iteration #{i}:"
    # busy_workers.each { |worker| puts "task=#{worker[0]}, remaining: #{worker[1]}"}
    # puts

    prev_busy = busy_workers.length

    busy_workers = busy_workers.map do |task, time_remaining|
      if time_remaining == 1
        # task is finished now add it to visited
        visited << task

        # add its neighbours to visit if needed
        neighbours = adjacency[task] || []
        neighbours.each do |neighbour|
          reverse = reverse_adjacency[neighbour]
          reverse.delete(task)
          if reverse.empty?
            index_to_insert_before = to_visit.bsearch_index { _1 >= neighbour }
            if index_to_insert_before.nil?
              to_visit << neighbour
            else
              to_visit.insert(index_to_insert_before, neighbour)
            end
          end
        end

        # free up the worker
        nil
      else
        [task, time_remaining - 1]
      end
    end.compact
    free_workers += prev_busy - busy_workers.length

    while free_workers > 0 && !to_visit.empty?
      visiting = to_visit.shift
      time_required = step_to_runtime(visiting, base_step_runtime)

      # puts "scheduling worker #{free_worker} on task #{visiting} for #{time_required} seconds at iteration #{i}"
      busy_workers << [visiting, time_required]
      free_workers -= 1
    end
    i += 1
  end
  i - 1
end


def compute_part_two(raw, num_workers, base_step_runtime)
  edges = raw.map { parse_raw_edge(_1) }
  workers = [[nil, 0]] * num_workers

  adjacency = {}
  reverse_adjacency = {}
  edges.each do |v1, v2|
    if adjacency.include?(v1)
      adjacency[v1].push(v2)
    else
      adjacency[v1] = [v2]
    end

    if reverse_adjacency.include?(v2)
      reverse_adjacency[v2].push(v1)
    else
      reverse_adjacency[v2] = [v1]
    end
  end

  roots = Set.new(edges.flat_map { _1 })
  edges.each do |v1, v2|
    roots.delete(v2)
  end

  to_visit = roots.sort
  visited = []
  i = 0
  while !to_visit.empty? || workers.any? { |task, time| time > 0 }
    workers.map! do |task, time_remaining|
      next [nil, 0] if task.nil?

      if time_remaining == 1
        # task is finished now add it to visited
        visited << task

        # add its neighbours to visit if needed
        neighbours = adjacency[task] || []
        neighbours.each do |neighbour|
          reverse = reverse_adjacency[neighbour]
          reverse.delete(task)
          if reverse.empty?
            to_visit << neighbour
          end
        end

        # free up the worker
        [nil, 0]
      else
        [task, time_remaining - 1]
      end
    end
    to_visit.sort!

    free_workers = workers
      .each_with_index
      .reject { |work, i| work[1] > 0 }
      .map { |work, i| i }

    while !free_workers.empty? && !to_visit.empty?
      free_worker = free_workers.shift
      visiting = to_visit.shift
      time_required = step_to_runtime(visiting, base_step_runtime)

      # puts "scheduling worker #{free_worker} on task #{visiting} for #{time_required} seconds at iteration #{i}"
      workers[free_worker] = [visiting, time_required]
    end

    # puts "workers after iteration #{i}:"
    # workers.each { |worker| puts "task=#{worker[0]}, remaining: #{worker[1]}"}
    # puts
    i += 1
  end
  i
end

reader = InputReader.new(7)

TEST_INPUT = <<~INPUT
Step C must be finished before step A can begin.
Step C must be finished before step F can begin.
Step A must be finished before step B can begin.
Step A must be finished before step D can begin.
Step B must be finished before step E can begin.
Step D must be finished before step E can begin.
Step F must be finished before step E can begin.
INPUT

# puts "part 1 - test data: #{compute_part_one(TEST_INPUT.split("\n"))}"
# puts "part 1: #{compute_part_one(reader.as_lines)}"
# puts "part 2 - test data: #{compute_part_two_faster(TEST_INPUT.split("\n"), 2, 0)}"
# puts "part 2: #{compute_part_two_faster(reader.as_lines, NUM_WORKERS + 1, BASE_STEP_RUNTIME)}"

require 'benchmark/ips'

Benchmark.ips do |x|
  x.report("part 2 - fast") do
    compute_part_two_faster(reader.as_lines, NUM_WORKERS, BASE_STEP_RUNTIME)
  end
  x.report("part 2 - slow") do
    compute_part_two(reader.as_lines, NUM_WORKERS, BASE_STEP_RUNTIME)
  end

  x.compare!
end
