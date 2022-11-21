require_relative './input_reader'

def grid_for_serial(serial)
  grid = (1..300).map do |y|
    (1..300).map do |x|
      rack_id = x + 10
      power = rack_id * y
      power += serial
      power *= rack_id
      power = (power / 100) % 10
      power -= 5
    end
  end
  grid
end

def compute_part_one(serial)
  grid = grid_for_serial(serial)

  max = -Float::INFINITY
  max_x = -1
  max_y = -1


  grid.each_with_index do |xs, j|
    break if j >= 300 - 3

    xs.each_with_index do |ys, i|
      break if i >= 300 - 3

      power = grid[j...j + 3].map { _1[i...i + 3].sum }.sum
      if power > max
        max = power
        max_x = i + 1
        max_y = j + 1
      end
      i += 1
    end
  end

  [max_x, max_y]
end

def compute_part_two(serial)
  grid = grid_for_serial(serial)

  summed_area_table = []
  (0..300).each do |y|
    row = []
    (0..300).each do |x|
      if x == 0 || y == 0
        row << 0
      else
        row << nil
      end
    end
    summed_area_table << row
  end

  grid.each.with_index(1) do |row, y|
    row.each.with_index(1) do |cell, x|
      left = summed_area_table[y][x-1]
      up = summed_area_table[y-1][x]
      diag = summed_area_table[y-1][x-1]

      raise if left.nil? || up.nil? || diag.nil?

      summed_area_table[y][x] = cell + left + up - diag
    end
  end

  max_power = -Float::INFINITY
  max_x, max_y, max_size = [0, 0, 0]

  (1..300).each do |size|
    (1..301 - size).each do |y|
      (1..301 - size).each do |x|
        top_left = summed_area_table[y][x]
        top_right = summed_area_table[y][x + size - 1]
        bottom_left = summed_area_table[y + size - 1][x]
        bottom_right = summed_area_table[y + size - 1][x + size - 1]

        power = bottom_right - bottom_left - top_right + top_left

        if power > max_power
          max_power = power
          max_x = x
          max_y = y
          max_size = size
        end
      end
    end
  end

  return "#{max_x},#{max_y},#{max_size}"
end

# tests
raise unless grid_for_serial(8)[4][2] == 4
raise unless grid_for_serial(57)[78][121] == -5
raise unless grid_for_serial(39)[195][216] == 0
raise unless grid_for_serial(71)[152][100] == 4

# puts "part 1 - test data: #{compute_part_one(42)}"
# puts "part 1: #{compute_part_one(1723)}"
# puts "part 2 - test: #{compute_part_two(18)}"
puts "part 2: #{compute_part_two(1723)}"
