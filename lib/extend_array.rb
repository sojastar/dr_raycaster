class Array
  def add(other)
    self.map.with_index { |e,i| e + other[i] }
  end

  def sub(other)
    self.map.with_index { |e,i| e - other[i] }
  end

  def mul(n)
    self.map { |e| n * e }
  end
end
