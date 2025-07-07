class Array
  def add(other)
    [ at(0) + other[0], at(1) + other[1] ]
  end

  def sub(other)
    [ at(0) - other[0], at(1) - other[1] ]
  end

  def mul(n)
    [ n * at(0), n * at(1) ] 
  end

  def inverse
    [ -at(0), -at(1) ]
  end

  def round(n)
    [ at(0).round(n), at(1).round(n) ]
  end
end
