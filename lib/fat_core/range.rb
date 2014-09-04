class Range
  # Return a range that concatenates this range with other; return nil
  # if the ranges are not contiguous.
  def join(other)
    if left_contiguous?(other)
      Range.new(min, other.max)
    elsif right_contiguous?(other)
      Range.new(other.min, max)
    else
      nil
    end
  end

  # Is self on the left of and contiguous to other?
  def left_contiguous?(other)
    if max.respond_to?(:succ)
      max.succ == other.min
    else
      max == other.min
    end
  end

  # Is self on the right of and contiguous to other?
  def right_contiguous?(other)
    if other.max.respond_to?(:succ)
      other.max.succ == min
    else
      other.max == min
    end
  end

  def contiguous?(other)
    left_contiguous?(other) || right_contiguous?(other)
  end

  def subset_of?(other)
    min >= other.min && max <= other.max
  end

  def proper_subset_of?(other)
    min > other.min && max < other.max
  end

  def superset_of?(other)
    min <= other.min && max >= other.max
  end

  def proper_superset_of?(other)
    min < other.min && max > other.max
  end

  def overlaps?(other)
    (cover?(other.min) || cover?(other.max) ||
     other.cover?(min) || other.cover?(max))
  end

  def intersection(other)
    return nil unless self.overlaps?(other)
    ([self.min, other.min].max..[self.max, other.max].min)
  end
  alias_method :&, :intersection

  def union(other)
    return nil unless self.overlaps?(other)
    ([self.min, other.min].min..[self.max, other.max].max)
  end
  alias_method :+, :union

  # The difference method, -, removes the overlapping part of the other
  # argument from self.  Because in the case where self is a superset of the
  # other range, this will result in the difference being two non-contiguous
  # ranges, this returns an array of ranges.  If there is no overlap or if
  # self is a subset of the other range, return an empty array
  def difference(other)
    unless max.respond_to?(:succ) && min.respond_to?(:pred) &&
        other.max.respond_to?(:succ) && other.min.respond_to?(:pred)
      raise "Range difference operation requires objects have pred and succ methods"
    end
    # return [] unless self.overlaps?(other)
    if proper_superset_of?(other)
      [(min..other.min.pred),
       (other.max.succ..max)]
    elsif subset_of?(other)
      []
    elsif overlaps?(other) && other.min <= min
      [(other.max.succ .. max)]
    elsif overlaps?(other) && other.max >= max
      [(min .. other.min.pred)]
    else
      []
    end
  end
  alias_method :-, :difference

  # Return whether any of the ranges that are within self overlap one
  # another
  def has_overlaps_within?(ranges)
    result = false
    unless ranges.empty?
      ranges.each do |r1|
        next unless overlaps?(r1)
        result =
          ranges.any? do |r2|
          r1.object_id != r2.object_id && overlaps?(r2) &&
            r1.overlaps?(r2)
        end
        return true if result
      end
    end
    result
  end

  # Return true if the given ranges collectively cover this range
  # without overlaps.
  def spanned_by?(ranges)
    joined_range = nil
    ranges.sort_by {|r| r.min}.each do |r|
      unless joined_range
        joined_range = r
        next
      end
      joined_range = joined_range.join(r)
      break if joined_range.nil?
    end
    if !joined_range.nil?
      joined_range.min <= min && joined_range.max >= max
    else
      false
    end
  end

  # If this range is not spanned by the ranges collectively, return an array
  # of ranges representing the gaps in coverage.  Otherwise return an empty
  # array.
  def gaps(ranges)
    if ranges.empty?
      [self.clone]
    elsif spanned_by?(ranges)
      []
    else
      ranges = ranges.sort_by {|r| r.min}
      gaps = []
      cur_point = min
      ranges.each do |rr|
        if rr.min > cur_point
          start_point = cur_point
          end_point = rr.min.pred
          gaps << (start_point..end_point)
        end
        cur_point = rr.max.succ
      end
      if cur_point < max
        gaps << (cur_point..max)
      end
      gaps
    end
  end

  # Similar to gaps, but within this range return the /overlaps/ among the
  # given ranges.  If there are no overlaps, return an empty array. Don't
  # consider overlaps in the ranges that occur outside of self.
  def overlaps(ranges)
    if ranges.empty? || spanned_by?(ranges)
      []
    else
      ranges = ranges.sort_by {|r| r.min}
      overlaps = []
      cur_point = nil
      ranges.each do |rr|
        # Skip ranges outside of self
        next if rr.max < min || rr.min > max
        # Initialize cur_point to max of first range
        if cur_point.nil?
          cur_point = rr.max
          next
        end
        # We are on the second or later range
        if rr.min < cur_point
          start_point = rr.min
          end_point = cur_point
          overlaps << (start_point..end_point)
        end
        cur_point = rr.max
      end
      overlaps
    end
  end

  # Allow erb documents can directly interpolate ranges
  def tex_quote
    to_s
  end
end
