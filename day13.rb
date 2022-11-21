require_relative './input_reader'
require 'set'

def compute_part_one(grid)
  ticknum = 0
  while !grid.collision?
    grid.tick
    ticknum += 1
  end

  puts "collision after #{ticknum} ticks"

  grid.collisions
end

def compute_part_two(grid)
  ticknum = 0
  puts "carts at start: #{grid.carts.length}"
  while grid.carts.length > 1
    ticknum += 1
    grid.tick
    # grid.remove_collisions
  end

  last_cart = grid.carts.first
  [last_cart.x, last_cart.y]
end

class Direction
  CART_SYMS = Set.new([">", "<", "^", "v"]).freeze

  def initialize(sym)
    @sym = sym
  end

  def turn(map_sym)
    case map_sym
    when "\\"
      @sym = case @sym
      when ">"
        "v"
      when "v"
        ">"
      when "^"
        "<"
      when "<"
        "^"
      end
    when "/"
      @sym = case @sym
      when ">"
        "^"
      when "^"
        ">"
      when "<"
        "v"
      when "v"
        "<"
      end
    end
  end

  def left
    case @sym
    when ">"
      @sym = "^"
    when "^"
      @sym = "<"
    when "<"
      @sym = "v"
    when "v"
      @sym = ">"
    end

    @sym
  end

  def right
    case @sym
    when ">"
      @sym = "v"
    when "v"
      @sym = "<"
    when "<"
      @sym = "^"
    when "^"
      @sym = ">"
    end

    @sym
  end

  def straight
    @sym
  end

  def tick
    case @sym
    when ">"
      [1, 0]
    when "<"
      [-1, 0]
    when "v"
      [0, 1]
    when "^"
      [0, -1]
    end
  end

  def self.is_direction?(sym)
    CART_SYMS.include?(sym)
  end

  def to_s
    @sym
  end
end


class Cart
  TO_TURN = ["\\", "/", "+"].freeze

  attr_accessor :x, :y, :direction

  def initialize(x, y, direction)
    @x = x
    @y = y
    @direction = direction
    @next_directions = ['left', 'straight', 'right']
  end

  def maybe_turn(map_sym)
    return unless TO_TURN.include?(map_sym)

    case map_sym
    when "+"
      turn
    when "\\", "/"
      @direction.turn(map_sym)
    end
  end

  def turn
    next_direction = @next_directions.first
    case next_direction
    when 'left'
      @direction.left
    when 'right'
      @direction.right
    when 'straight'
      @direction.straight
    end

    @next_directions.rotate!
  end

  def tick
    dx, dy = @direction.tick
    @x += dx
    @y += dy
  end

  def <=>(other)
    [@x, @y] <=> [other.x, other.y]
  end
end

class CartGrid
  attr_reader :carts, :grid

  def initialize(grid)
    @grid = grid
    @carts = []
    @intersections = Set.new

    grid.each_with_index do |row, y|
      row.each_with_index do |map, x|
        if Direction.is_direction?(map)
          direction = Direction.new(map)
          cart = Cart.new(x, y, direction)
          @carts << cart
          case map
          when 'v', '^'
            @grid[y][x] = '|'
          when '>', '<'
            @grid[y][x] = '-'
          else
            raise "dunno how to handle"
          end
        elsif map == '+'
          @intersections.add([x, y])
        end
      end
    end

    @carts.sort!
  end

  def tick
    carts_to_tick = @carts.clone

    while !carts_to_tick.empty?
      cart = carts_to_tick.shift
      cart.tick

      dups = @carts.select { _1 != cart && _1.x == cart.x && _1.y == cart.y }
      if !dups.empty?
        puts "removing cart with x=#{cart.x} and y=#{cart.y}"
        @carts = @carts.reject { _1.x == cart.x && _1.y == cart.y }
        carts_to_tick = carts_to_tick.reject {  _1.x == cart.x && _1.y == cart.y  }
      else
        current = @grid[cart.y][cart.x]
        cart.maybe_turn(current)
      end
    end

    @carts.sort!
  end

  def print_out
    cloned = @grid.map { _1.clone }
    @carts.each do |cart|
      if ["<", ">", "^", "v"].include?(cloned[cart.y][cart.x])
        cloned[cart.y][cart.x] = 'X'
      else
        cloned[cart.y][cart.x] = cart.direction.to_s
      end
    end

    puts cloned.map { _1.join }.join("\n")
    puts "\n"
  end

  def remove_collisions
    return unless collision?

    collision_coords = collisions
    new_carts = @carts.reject { collision_coords.include?([_1.x, _1.y]) }
    delta = @carts.length - new_carts.length
    @carts = new_carts
    delta
  end

  def collision?
    cart_coords = @carts.map { [_1.x, _1.y] }
    cart_coords.any? { cart_coords.count(_1) > 1 }
  end

  def collisions
    return [] unless collision?

    cart_coords = @carts.map { [_1.x, _1.y] }
    cart_coords.select { cart_coords.count(_1) > 1 }.uniq
  end
end

def parse_raw(lines)
  grid = lines.map { _1.chars }
  CartGrid.new(grid)
end

def test_input
  input = <<-'INPUT'.split("\n")
/->-\
|   |  /----\
| /-+--+-\  |
| | |  | v  |
\-+-/  \-+--/
  \------/
  INPUT
  parse_raw(input)
end

def test_input_two
  input = <<-'INPUT'.split("\n")
/>-<\
|   |
| /<+-\
| | | v
\>+</ |
  |   ^
  \<->/
end
  INPUT
  parse_raw(input)
end

def prod_input
  input_reader = InputReader.new(13)
  lines = input_reader.as_lines(chomp: false)
  parse_raw(input_reader.as_lines(chomp: false))
end

# puts "part 1 - test: #{compute_part_one(test_input)}"
# puts "part 1 - #{compute_part_one(prod_input)}"
# puts "part 2 - test1 - #{compute_part_two(test_input)}"
puts "part 2 - test - #{compute_part_two(test_input_two)}"
puts "part 2 - #{compute_part_two(prod_input)}"
