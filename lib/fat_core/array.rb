class Array
  def last_i
    self.size - 1
  end

  # Return a new array that is the intersection of this Array with other, but
  # without removing duplicates as the :& method does. All items of the first
  # array are included in the result but only if they also appear in the other
  # array.
  def intersect(other)
    result = []
    each do |itm|
      result << itm if other.include?(itm)
    end
    result
  end

  # Return an array that is the difference between this Array and the other, but
  # without removing duplicates as the :- method does. All items of the first
  # array are included in the result unless they also appear in the other array.
  def difference(other)
    result = []
    each do |itm|
      result << itm unless other.include?(itm)
    end
    result
  end
end
