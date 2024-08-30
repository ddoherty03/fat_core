# frozen_string_literal: true

# Useful extensions to the core Enumerable module.
module Enumerable
  # Yield items in groups of n, for each group yield the group number, starting
  # with zero and an Array of n items, or all remaining items if less than n.
  #
  #    ('a'..'z').to_a.groups_of(5) do |k, grp|
  #      # On each iteration, grp is an Array of the next 5 items except the
  #      # last group, which contains only ['z'].
  #    end
  def groups_of(num)
    k = -1
    group_by do
      k += 1
      k.div(num)
    end
  end

  # Yield each item together with two booleans that indicate whether the item is
  # the first or last item in the Enumerable.
  #
  #    ('a'..'z').to_a.each with_flags do |letter, first, last|
  #      if first
  #        # do something special for 'a'
  #      elsif last
  #        # do something special for 'z'
  #      else
  #        # a middling item
  #      end
  #    end
  def each_with_flags
    # Test for beginless range
    return nil if is_a?(Range) && self.begin.nil?

    last_k = size - 1
    each_with_index do |v, k|
      first = k.zero?
      last  = (k == last_k)
      yield(v, first, last)
    end
  end
end
