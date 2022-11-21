require_relative './input_reader'

# def compute_part_one(line)
#   did_destroy = true
#
#   current_chars = line.chars
#   new_chars = []
#   deleted_pairs = []
#
#   while did_destroy do
#     did_destroy = false
#
#     i = 0
#     while i < current_chars.length
#       if i == current_chars.length - 1
#         new_chars << current_chars[i]
#         break
#       elsif current_chars[i].downcase != current_chars[i + 1].downcase
#         new_chars << current_chars[i]
#         i += 1
#       elsif current_chars[i] == current_chars[i + 1]
#         new_chars << current_chars[i]
#         i += 1
#       else
#         deleted_pairs << [current_chars[i], current_chars[i + 1]]
#         did_destroy = true
#         i += 2
#       end
#     end
#     current_chars = new_chars
#     new_chars = []
#   end
#
#   current_chars[...-1].each_with_index do |_, i|
#     if current_chars[i].downcase == current_chars[i + 1].downcase && current_chars[i] != current_chars[i + 1]
#       raise
#     end
#   end
#   current_chars.length
# end
#
def compute_part_one(line)
  i = 0
  maxlength = line.length
  chars = line.chars
  while i < maxlength do
    break if i == maxlength - 1

    if chars[i].downcase != chars[i + 1].downcase
      i += 1
    elsif chars[i] == chars[i + 1]
      i += 1
    else
      head = chars[0...i]
      tail = chars[i + 2..]
      chars = head + tail
      maxlength -= 2
      i = [i-1, 0].max
    end
  end
  chars.length
end

def compute_part_two(line)
  min_cost = Float::INFINITY
  ('a'..'z').each do |char|
    re = Regexp.compile("[#{char}#{char.upcase}]")
    new_line = line.gsub(re, "")
    cost = compute_part_one(new_line)

    if cost < min_cost
      min_cost = cost
    end
  end

  min_cost
end

reader = InputReader.new(5)

puts "test case for part 1: #{compute_part_one("dabAcCaCBAcCcaDA")}"
puts "part 1: #{compute_part_one(reader.as_line)}"
puts "test case for part 3: #{compute_part_two("dabAcCaCBAcCcaDA")}"
puts "part 2: #{compute_part_two(reader.as_line)}"
