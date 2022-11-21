require_relative './input_reader'
require 'benchmark'
require 'set'

class Claim
  attr_reader :id, :x, :y, :width, :height

  def initialize(id, x, y, width, height)
    @id = id
    @x = x
    @y = y
    @width = width
    @height = height
  end

  def self.parse(claim)
    matches = /^#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/.match(claim)

    Claim.new(
      matches[1],
      matches[2].to_i,
      matches[3].to_i,
      matches[4].to_i,
      matches[5].to_i
    )
  end

  def to_s
    "Claim: id=#{@id}, x=#{@x}, y=#{@y}, width=#{@width}, height=#{@height}"
  end
end

def compute_part_one(reader)
  claims = reader.as_lines.map { Claim.parse(_1) }
  overlaps = {}

  claims.each do |claim|
    (claim.x...claim.x + claim.width).each do |x|
      (claim.y...claim.y + claim.height).each do |y|
        if overlaps.include?([x, y]) && overlaps[[x, y]]
          next
        elsif overlaps.include?([x, y])
          overlaps[[x, y]] = true
        else
          overlaps[[x, y]] = false
        end
      end
    end
  end

  overlaps.count { _2 }
end

def compute_part_two(reader)
  claims = reader.as_lines.map { Claim.parse(_1) }
  overlaps = {}
  claims_with_overlap = {}

  claims.each do |claim|
    (claim.x...claim.x + claim.width).each do |x|
      (claim.y...claim.y + claim.height).each do |y|
        if overlaps.include?([x, y])
          overlaps[[x, y]].add(claim.id)
          overlaps[[x, y]].each { claims_with_overlap[_1] = true }
        else
          overlaps[[x, y]] = Set.new([claim.id])
        end
      end
    end
  end

  Set.new(claims.map(&:id)) - Set.new(claims_with_overlap.keys)
end

reader = InputReader.new(3)

puts "part 1: #{compute_part_one(reader)}"
puts "part 2: #{compute_part_two(reader)}"
