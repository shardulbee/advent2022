class InputReader
  DATA_DIR = "./data"

  def initialize(day_number)
    @day_number = day_number
    @path = File.join(DATA_DIR, "day#{@day_number}.data")
  end

  def as_lines(chomp: true)
    IO.readlines(@path, chomp: chomp)
  end

  def as_line
    IO.read(@path).chomp
  end

  def as_ints
    IO.read(@path).chomp.split(" ").map(&:to_i)
  end
end
