module Enumerable
  # Emit item in groups of n
  def groups_of(n)
    k = -1
    group_by { |item| k += 1; k.div(n) }
  end
end
