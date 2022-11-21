require_relative './input_reader'
require 'time'

class LogLine
  LINE_FORMAT = /^\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2})\] (.*)$/
  GUARD_FORMAT = /^Guard #(\d+) begins shift/

  attr_accessor :timestamp, :action, :id, :shift_id

  def initialize(timestamp, action, id, shift_id: nil)
    @timestamp = timestamp
    @action = action
    @id = id
    @shift_id = shift_id
  end

  def self.parse(line)
    matches = LINE_FORMAT.match(line)
    timestamp = Time.strptime("#{matches[1]} UTC", '%Y-%m-%d %H:%M %Z')
    case matches[2]
    when 'falls asleep'
      id = nil
      action = 'sleep'
    when 'wakes up'
      id = nil
      action = 'awaken'
    else
      id = GUARD_FORMAT.match(matches[2])[1]
      action = 'start'
    end

    new(timestamp, action, id)
  end
end

def parse_lines(lines)
  sorted_logs = lines.map do |line|
    LogLine.parse(line)
  end.sort_by(&:timestamp)

  current_guard = nil
  current_shift_id = 0
  sorted_logs.each do |log|
    if !log.id.nil?
      current_guard = log.id
      current_shift_id += 1
    elsif !current_guard.nil?
      log.id = current_guard
    else
      raise
    end
    log.shift_id = current_shift_id
  end

  sorted_logs
end

def compute_part_one(reader)
  logs = parse_lines(reader.as_lines())
  grouped = logs.group_by { [_1.id, _1.shift_id] }
  segments_by_id = grouped.flat_map do |key, shifts|
    guard_id, shift_id = key
    sleep_segments = shifts
      .reject { _1.action == 'start' }
      .each_slice(2)
      .map { |t1, t2| [t1.timestamp.min, t2.timestamp.min] }
    sleep_segments.map { {id: guard_id, segment: _1} }
  end

  most_sleepy_id, _ = segments_by_id
    .group_by { _1[:id] }
    .max_by do |id, segments|
      segments.sum { _1[:segment][1] - _1[:segment][0] }
    end

  hour_bitmap = [0] * 60

  segments_by_id
    .select { _1[:id] == most_sleepy_id }
    .each do |segment|
      (segment[:segment][0]...segment[:segment][1]).each do
        hour_bitmap[_1] += 1
      end
    end

  return hour_bitmap.each_with_index.max[1] * most_sleepy_id.to_i
end

def compute_part_two(reader)
  logs = parse_lines(reader.as_lines())
  grouped = logs.group_by { [_1.id, _1.shift_id] }
  segments_by_id = grouped.flat_map do |key, shifts|
    guard_id, shift_id = key
    sleep_segments = shifts
      .reject { _1.action == 'start' }
      .each_slice(2)
      .map { |t1, t2| [t1.timestamp.min, t2.timestamp.min] }
    sleep_segments.map { {guard_id: guard_id, sleep_segment: _1} }
  end

  guard_bitmap = {}
  segments_by_id.map { _1[:guard_id] }.uniq.each do |id|
    guard_bitmap[id] = [0] * 60
  end

  segments_by_id.each do |shift|
    (shift[:sleep_segment][0]...shift[:sleep_segment][1]).each do |min|
      guard_bitmap[shift[:guard_id]][min] += 1
    end
  end

  max_guard_id, bitmap = guard_bitmap.max_by { |guard_id, bitmap| bitmap.max }
  max_guard_id.to_i * bitmap.each.with_index.max[1]
end

reader = InputReader.new(4)

puts "part 1: #{compute_part_one(reader)}"
puts "part 2: #{compute_part_two(reader)}"

