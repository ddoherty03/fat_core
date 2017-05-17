# FatCore extends the Range class with methods that
#
# 1. provide some set operations operations on Ranges, union, intersection, and
#    difference,
# 2. test for overlapping and contiguity between Ranges,
# 3. test for whether one Range is a subset or superset of another,
# 3. join contiguous Ranges,
# 4. find whether a set of Ranges spans a large range, and if not, to return
#    a set of Ranges that represent gaps in the coverage or overlaps in
#    coverage,
# 5. provide a definition for sorting Ranges based on sorting by the min values
#    and sizes of the Ranges.
module FatCore
  module Range
    # @group Operations

    # Return a range that concatenates this range with other if it is contiguous
    # with this range on the left or right; return nil if the ranges are not
    # contiguous.
    #
    # @example
    #    (0..3).join(4..8) #=> (0..8)
    #
    # @param other [Range] the Range to join to this range
    # @return [Range, nil] this range joined to other
    #
    # @see contiguous? For the definition of "contiguous"
    def join(other)
      if left_contiguous?(other)
        ::Range.new(min, other.max)
      elsif right_contiguous?(other)
        ::Range.new(other.min, max)
      end
    end

    # If this range is not spanned by the `ranges` collectively, return an Array
    # of ranges representing the gaps in coverage.  The `ranges` can over-cover
    # this range on the left or right without affecting the result, that is,
    # each range in the returned array of gap ranges will always be subsets of
    # this range.
    #
    # If the `ranges` span this range, return an empty array.
    #
    # @example
    #   (0..10).gaps([(0..3), (5..6), (9..10)])  #=> [(4..4), (7..8)]
    #   (0..10).gaps([(-4..3), (5..6), (9..15)]) #=> [(4..4), (7..8)]
    #   (0..10).gaps([(-4..3), (4..6), (7..15)]) #=> [] ranges span this one
    #   (0..10).gaps([(-4..-3), (11..16), (17..25)]) #=> [(0..10)] no overlap
    #   (0..10).gaps([])                             #=> [(0..10)] no overlap
    #
    # @param ranges [Array<Range>]
    # @return [Array<Range>]
    def gaps(ranges)
      if ranges.empty?
        [clone]
      elsif spanned_by?(ranges)
        []
      else
        ranges = ranges.sort_by(&:min)
        gaps = []
        cur_point = min
        ranges.each do |rr|
          break if rr.min > max
          if rr.min > cur_point
            start_point = cur_point
            end_point = rr.min.pred
            gaps << (start_point..end_point)
            cur_point = rr.max.succ
          elsif rr.max >= cur_point
            cur_point = rr.max.succ
          end
        end
        gaps << (cur_point..max) if cur_point <= max
        gaps
      end
    end

    # Within this range return an Array of Ranges representing the overlaps
    # among the given Array of Ranges `ranges`. If there are no overlaps, return
    # an empty array. Don't consider overlaps in the `ranges` that occur outside
    # of self.
    #
    # @example
    #  (0..10).overlaps([(-4..4), (2..7), (5..12)]) => [(2..4), (5..7)]
    #
    # @param ranges [Array<Range>] ranges to search for overlaps
    # @return [Array<Range>] overlaps with ranges but inside this Range
    def overlaps(ranges)
      if ranges.empty? || spanned_by?(ranges)
        []
      else
        ranges = ranges.sort_by(&:min)
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

    # Return a Range that represents the intersection between this range and the
    # `other` range.  If there is no intersection, return nil.
    #
    # @example
    #   (0..10) & (5..20)             #=> (5..10)
    #   (0..10).intersection((5..20)) #=> (5..10)
    #   (0..10) & (15..20)            #=> nil
    #
    # @param other [Range] the Range self is intersected with
    # @return [Range, nil] a Range representing the intersection
    def intersection(other)
      return nil unless overlaps?(other)
      ([min, other.min].max..[max, other.max].min)
    end
    alias & intersection

    # Return a Range that represents the union between this range and the
    # `other` range.  If there is no overlap and self is not contiguous with
    # `other`, return `nil`.
    #
    # @example
    #   (0..10) + (5..20)       #=> (0..20)
    #   (0..10).union((5..20))  #=> (0..20)
    #   (0..10) + (15..20)      #=> nil
    #
    # @param other [Range] the Range self is union-ed with
    # @return [Range, nil] a Range representing the union
    def union(other)
      return nil unless overlaps?(other) || contiguous?(other)
      ([min, other.min].min..[max, other.max].max)
    end
    alias + union

    # The difference method, -, removes the overlapping part of the other
    # argument from self.  Because in the case where self is a superset of the
    # other range, this will result in the difference being two non-contiguous
    # ranges, this returns an array of ranges.  If there is no overlap or if
    # self is a subset of the other range, return an array of self
    def difference(other)
      unless max.respond_to?(:succ) && min.respond_to?(:pred) &&
             other.max.respond_to?(:succ) && other.min.respond_to?(:pred)
        raise 'Range difference requires objects have pred and succ methods'
      end
      if subset_of?(other)
        # (4..7) - (0..10)
        []
      elsif proper_superset_of?(other)
        # (4..7) - (5..5) -> [(4..4), (6..7)]
        [(min..other.min.pred), (other.max.succ..max)]
      elsif overlaps?(other) && other.min <= min
        # (4..7) - (2..5) -> (6..7)
        [(other.max.succ..max)]
      elsif overlaps?(other) && other.max >= max
        # (4..7) - (6..10) -> (4..5)
        [(min..other.min.pred)]
      else
        [self]
      end
    end
    alias - difference

    # Allow erb or erubis documents to directly interpolate a Range.
    #
    # @return [String]
    def tex_quote
      to_s
    end

    # @group Queries

    # Is self on the left of and contiguous to other?  Whether one range is
    # "contiguous" to another has two cases:
    #
    # 1. If the elements of the Range on the left respond to the #succ method
    #    (that is, its values are discrete values such as Integers or Dates)
    #    test whether the succ to the max value of the Range on the left is
    #    equal to the min value of the Range on the right.
    # 2. If the elements of the Range on the left do not respond to the #succ
    #    method (that is, its values are continuous values such as Floats) test
    #    whether the max value of the Range on the left is equal to the min
    #    value of the Range on the right
    #
    # @example
    #    (0..10).left_contiguous((11..20))           #=> true
    #    (11..20).left_contiguous((0..10))           #=> false, but right_contiguous
    #    (0.5..3.145).left_contiguous((3.145..18.4)) #=> true
    #    (0.5..3.145).left_contiguous((3.146..18.4)) #=> false
    #
    # @param other [Range] other range to test for contiguity
    # @return [Boolean] is self left_contiguous with other
    def left_contiguous?(other)
      if max.respond_to?(:succ)
        max.succ == other.min
      else
        max == other.min
      end
    end

    # Is self on the right of and contiguous to other?  Whether one range is
    # "contiguous" to another has two cases:
    #
    # 1. If the elements of the Range on the left respond to the #succ method
    #    (that is, its values are discrete values such as Integers or Dates)
    #    test whether the succ to the max value of the Range on the left is
    #    equal to the min value of the Range on the right.
    # 2. If the elements of the Range on the left do not respond to the #succ
    #    method (that is, its values are continuous values such as Floats) test
    #    whether the max value of the Range on the left is equal to the min
    #    value of the Range on the right
    #
    # @example
    #    (11..20).right_contiguous((0..10))           #=> true
    #    (0..10).right_contiguous((11..20))           #=> false, but left_contiguous
    #    (3.145..12.3).right_contiguous((0.5..3.145)) #=> true
    #    (3.146..12.3).right_contiguous((0.5..3.145)) #=> false
    #
    # @param other [Range] other range to test for contiguity
    # @return [Boolean] is self right_contiguous with other
    def right_contiguous?(other)
      if other.max.respond_to?(:succ)
        other.max.succ == min
      else
        other.max == min
      end
    end

    # Is self contiguous to other either on the left or on the right? First, the
    # two ranges are sorted by their min values, and the range with the lowest
    # min value is considered to be on the "left" and the other range on the
    # "right". Whether one range is "contiguous" to another then has two cases:
    #
    # 1. If the max element of the Range on the left respond to the #succ method
    #    (that is, its value is a discrete value such as Integer or Date)
    #    test whether the succ to the max value of the Range on the left is
    #    equal to the min value of the Range on the right.
    # 2. If the max element of the Range on the left does not respond to the
    #    #succ method (that is, its values are continuous values such as Floats)
    #    test whether the max value of the Range on the left is equal to the min
    #    value of the Range on the right
    #
    # @example
    #   (0..10).contiguous?((11..20))           #=> true
    #   (11..20).contiguous?((0..10))           #=> true, right_contiguous
    #   (0..10).contiguous?((15..20))           #=> false
    #   (3.145..12.3).contiguous?((0.5..3.145)) #=> true
    #   (3.146..12.3).contiguous?((0.5..3.145)) #=> false
    #
    # @param other [Range] other range to test for contiguity
    # @return [Boolean] is self contiguous with other
    def contiguous?(other)
      left_contiguous?(other) || right_contiguous?(other)
    end

    # Return whether self is contained within `other` range, even if their
    # boundaries touch.
    #
    # @param other [Range] the containing range
    # @return [Boolean] is self within other
    def subset_of?(other)
      min >= other.min && max <= other.max
    end

    # Return whether self is contained within `other` range, without their
    # boundaries touching.
    #
    # @param other [Range] the containing range
    # @return [Boolean] is self wholly within other
    def proper_subset_of?(other)
      min > other.min && max < other.max
    end

    # Return whether self contains `other` range, even if their
    # boundaries touch.
    #
    # @param other [Range] the contained range
    # @return [Boolean] does self contain other
    def superset_of?(other)
      min <= other.min && max >= other.max
    end

    # Return whether self contains `other` range, without their
    # boundaries touching.
    #
    # @param other [Range] the contained range
    # @return [Boolean] does self wholly contain other
    def proper_superset_of?(other)
      min < other.min && max > other.max
    end

  # Return whether self overlaps with other Range.
  #
  # @param other [Range] range to test for overlap with self
  # @return [Boolean] is there an overlap?
  def overlaps?(other)
    (cover?(other.min) || cover?(other.max) ||
     other.cover?(min) || other.cover?(max))
  end

  # Return whether any of the `ranges` that overlap self have overlaps among one
  # another.
  #
  # This does the same thing as `Range.overlaps_among?`, except that it filters
  # the `ranges` to only those overlapping self before testing for overlaps
  # among them.
  #
  # @param ranges [Array<Range>] ranges to test for overlaps
  # @return [Boolean] were there overlaps among ranges?
  def overlaps_among?(ranges)
    iranges = ranges.select { |r| overlaps?(r) }
    Range.overlaps_among?(iranges)
  end

  # Return whether any of the `ranges` overlap one another
  #
  # @param ranges [Array<Range>] ranges to test for overlaps
  # @return [Boolean] were there overlaps among ranges?
  def self.overlaps_among?(ranges)
    result = false
    unless ranges.empty?
      ranges.each do |r1|
        result = ranges.any? do |r2|
          r1.object_id != r2.object_id && r1.overlaps?(r2)
        end
        return true if result
      end
    end
    result
  end

  # Return true if the given ranges collectively cover this range
  # without overlaps and without gaps.
  #
  # @param ranges [Array<Range>]
  # @return [Boolean]
  def spanned_by?(ranges)
    joined_range = nil
    ranges.sort.each do |r|
      unless joined_range
        joined_range = r
        next
    module ClassMethods
      # Return whether any of the `ranges` overlap one another
      #
      # @param ranges [Array<Range>] ranges to test for overlaps
      # @return [Boolean] were there overlaps among ranges?
      def overlaps_among?(ranges)
        result = false
        unless ranges.empty?
          ranges.each do |r1|
            result = ranges.any? do |r2|
              r1.object_id != r2.object_id && r1.overlaps?(r2)
            end
            return true if result
          end
        end
        result
      end
    end

    # @private
    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end

class Range
  include FatCore::Range
  # @!parse include FatCore::Range
  # @!parse extend FatCore::Range::ClassMethods
end
