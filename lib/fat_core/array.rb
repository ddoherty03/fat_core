class Array
  def last_i
    self.size - 1
  end

  # Return a new array that is the intersection of this Array with other, but
  # without removing duplicates as the :& method does.
  def intersect(other)
    result = []
    each do |itm|
      result << itm if other.include?(itm)
    end
    result
  end

  # Return an array that is the difference between this Array and the other, but
  # without removing duplicates as the :- method does.
  def difference(other)
    result = deep_dup
    other.each do |itm|
      if (k = result.index(itm))
        result.delete_at(k)
      end
    end
    result
  end
end
