module Enumerable
  # Yield items in groups of n, for each group yield the group number, starting
  # with zero and an Array of n items, or all remaining items if less than n.
  #
  #    ('a'..'z').to_a.groups_of(5) do |k, grp|
  #      # On each iteration, grp is an Array of the next 5 items except the
  #      # last group, which contains only ['z'].
  #    end
  def groups_of(n)
    k = -1
    group_by { k += 1; k.div(n) }
  end

  # Yield each item together with two booleans that indicate whether the item is
  # the first or last item in the Enumerable.
  #
  #    ('a'..'z').to_a.each with_flags do |letter, first, last|
  #      if first
  #        # do something special for the first item
  #      elsif last
  #        # do something special for the last item
  #      else
  #        # a middling item
  #      end
  #    end
  def each_with_flags
    last_k = size - 1
    each_with_index do |v, k|
      first = (k == 0 ? true : false)
      last  = (k == last_k ? true : false)
      yield(v, first, last)
    end
  end
end
