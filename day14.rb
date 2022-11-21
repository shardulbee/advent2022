INITIAL_RECIPES = [3, 7]
INITIAL_POSITIONS = [0, 1]

def compute_next_index(current_idx, recipes)
  (current_idx + recipes[current_idx] + 1) % recipes.length
end

def compute_part_one(improve_at_idx, scores_after)
  recipes = INITIAL_RECIPES.clone
  elf_positions = INITIAL_POSITIONS.clone
  idx = 0

  while recipes.length < improve_at_idx + scores_after
    idx += 1
    recipes.append(
      *elf_positions.map { recipes[_1] }.sum.to_s.chars.map(&:to_i)
    )
    elf_positions.map! { compute_next_index(_1, recipes) }
  end

  recipes[improve_at_idx...improve_at_idx + scores_after].map(&:to_s).join
end

def compute_part_two(sequence)
  recipes = INITIAL_RECIPES.clone
  elf_positions = INITIAL_POSITIONS.clone
  idx = 0

  queue = sequence.split("").map(&:to_i)
  stack = []

  while !queue.empty?
    idx += 1
    new_recipes = elf_positions.map { recipes[_1] }.sum.to_s.chars.map(&:to_i)

    # puts "before - stack: #{stack}, queue: #{queue}, new_recipes: #{new_recipes}"

    new_recipes.each do |recipe|
      if queue.empty?
        break
      elsif recipe == queue.first
        stack.push(queue.shift)
      elsif !stack.empty?
        while !stack.empty?
          queue.unshift(stack.pop)
        end
        stack.push(queue.shift) if recipe == queue.first
      end
      recipes << recipe
    end

    # puts "after - stack: #{stack}, queue: #{queue}"

    elf_positions.map! { compute_next_index(_1, recipes) }
  end
  recipes.length - stack.length
end

def test_input_one
  improve_at_idx = 9
  scores_after = 10
  expected = "5158916779"

  [improve_at_idx, scores_after, expected]
end

def test_input_two
  improve_at_idx = 5
  scores_after = 10
  expected = "0124515891"

  [improve_at_idx, scores_after, expected]
end

def prod_input_one
  improve_at_idx = 84601
  scores_after = 10

  [improve_at_idx, scores_after]
end

def test_problem_two_input_one
  sequence = "51589"
  expected = 9
  [sequence, expected]
end

def test_problem_two_input_two
  sequence = "01245"
  expected = 5
  [sequence, expected]
end

def test_problem_two_input_three
  sequence = "92510"
  expected = 18
  [sequence, expected]
end

def test_problem_two_input_four
  sequence = "59414"
  expected = 2018
  [sequence, expected]
end

# raise unless compute_part_one(*test_input_one[0..1]) == test_input_one[2]
# raise unless compute_part_one(*test_input_two[0..1]) == test_input_two[2]
#
# puts "part 1 - #{compute_part_one(*prod_input)}"

raise unless compute_part_two(test_problem_two_input_one[0]) == test_problem_two_input_one[1]
raise unless compute_part_two(test_problem_two_input_two[0]) == test_problem_two_input_two[1]
raise unless compute_part_two(test_problem_two_input_three[0]) == test_problem_two_input_three[1]
raise unless compute_part_two(test_problem_two_input_four[0]) == test_problem_two_input_four[1]

# puts "part 1 - test - #{compute_part_one(*test_input_one)}"
puts "part 2 - #{compute_part_two("084601")}"
