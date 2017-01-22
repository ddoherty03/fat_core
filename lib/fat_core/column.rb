module FatCore
  # Column objects are just a thin wrapper around an Array to allow columns to
  # be summed and have other operations performed on them, but compacting out
  # nils before proceeding. My original attempt to do this by monkey-patching
  # Array turned out badly.  This works much nicer.
  class Column
    attr_reader :items

    def initialize(items = [])
      @items = items
    end

    def <<(itm)
      items << itm
    end

    def [](k)
      items[k]
    end

    def to_a
      items
    end

    def size
      items.size
    end

    def last_i
      size - 1
    end

    def sum
      items.compact.sum
    end

    def min
      items.compact.min
    end

    def max
      items.compact.max
    end

    def avg
      sum / size.to_d
    end
  end
end
