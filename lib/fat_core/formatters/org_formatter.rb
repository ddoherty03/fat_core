module FatCore
  class OrgFormatter < Formatter

    self.default_format = default_format.dup
    self.default_format[:date_fmt] = '[%F]'
    self.default_format[:datetime_fmt] = '[%F %a %H:%M:%S]'

    # Does this Formatter require a second pass over the cells to align the
    # columns according to the alignment formatting instruction to the width of
    # the widest cell in each column?
    def aligned?
      true
    end

    # Should the string result of output be evaluated to form a ruby data
    # structure? For example, AoaFormatter wants to return an array of arrays of
    # strings, so it should build a ruby expression to do that, then have it
    # eval'ed.
    def evaluate?
      false
    end

    # Compute the width of the string as displayed, taking into account the
    # characteristics of the target device.  For example, a colored string
    # should not include in the width terminal control characters that simply
    # change the color without occupying any space.  Thus, this method must be
    # overridden in a subclass if a simple character count does not reflect the
    # width as displayed.
    def width(str)
      str.length
    end

    # Output
    def pre_table
      ''
    end

    def post_table
      ''
    end

    def include_header_row?
      true
    end

    def pre_header(widths)
      result = '|'
      widths.values.each do |w|
        result += '-' * (w + 2) + '+'
      end
      result[-1] = '|'
      result + "\n"
    end

    def post_header(widths)
      '' #hline(widths)
    end

    def pre_row
      '|'
    end

    # Add one space of padding.
    def pre_cell(_h)
      ' '
    end

    def quote_cell(v)
      v
    end

    # Add one space of padding.
    def post_cell
      ' '
    end

    def inter_cell
      '|'
    end

    def post_row
      "|\n"
    end

    def hline(widths)
      result = '|'
      widths.values.each do |w|
        result += '-' * (w + 2) + '+'
      end
      result[-1] = '|'
      result + "\n"
    end

    def pre_group
      ''
    end

    def post_group
      ''
    end

    def pre_gfoot
      ''
    end

    def post_gfoot
      ''
    end

    def pre_foot
      ''
    end

    def post_foot
      ''
    end
  end
end
