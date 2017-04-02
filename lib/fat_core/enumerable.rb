module Enumerable
  # Yield item in groups of n
  def groups_of(n)
    k = -1
    group_by { k += 1; k.div(n) }
  end

  # Yield each item together with booleans that indicate whether the item is the
  # first or last in the Enumerable.
  def each_with_flags
    last_k = size - 1
    each_with_index do |v, k|
      first = (k == 0 ? true : false)
      last  = (k == last_k ? true : false)
      yield(v, first, last)
    end
  end
end
