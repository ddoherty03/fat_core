module FatCore
  module Array
    # Return the index of the last element of this Array.  This is just a
    # convenience for an oft-needed Array attribute.
    def last_i
      self.size - 1
    end

    # Return a new Array that is the intersection of this Array with +other+,
    # but without removing duplicates as the Array#& method does. All items of
    # this Array are included in the result but only if they also appear in the
    # +other+ Array.
    def intersect(other)
      result = []
      each do |itm|
        result << itm if other.include?(itm)
      end
      result
    end

    # Return an Array that is the difference between this Array and +other+, but
    # without removing duplicates as the Array#- method does. All items of this
    # Array are included in the result unless they also appear in the +other+
    # Array.
    def difference(other)
      result = []
      each do |itm|
        result << itm unless other.include?(itm)
      end
      result
    end
  end
end

class Array
  include FatCore::Array
  # @!parse include FatCore::Array
end
