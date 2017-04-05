# -*- coding: utf-8 -*-

module FatCore
  # Output the table as for a unicode-enabled terminal.  This makes table
  # gridlines drawable with unicode characters, as well as supporting colored
  # text and backgrounds.plain text.

  class TermFormatter < Formatter
    def initialize(table = Table.new, **options)
      super
      @options[:unicode] = options.fetch(:unicode, true)
    end

    # Unicode line-drawing characters. We use double lines before and after the
    # table and single lines for the sides and hlines between groups and
    # footers.
    UPPER_LEFT = "\u2552".freeze
    UPPER_RIGHT = "\u2555".freeze
    DOUBLE_RULE = "\u2550".freeze
    UPPER_TEE = "\u2564".freeze
    VERTICAL_RULE = "\u2502".freeze
    LEFT_TEE = "\u251C".freeze
    HORIZONTAL_RULE = "\u2500".freeze
    SINGLE_CROSS = "\u253C".freeze
    RIGHT_TEE = "\u2524".freeze
    LOWER_LEFT = "\u2558".freeze
    LOWER_RIGHT = "\u255B".freeze
    LOWER_TEE = "\u2567".freeze

    def upper_left
      if options[:unicode]
        UPPER_LEFT
      else
        '+'
      end
    end

    def upper_right
      if options[:unicode]
        UPPER_RIGHT
      else
        '+'
      end
    end

    def double_rule
      if options[:unicode]
        DOUBLE_RULE
      else
        '='
      end
    end

    def upper_tee
      if options[:unicode]
        UPPER_TEE
      else
        '+'
      end
    end

    def vertical_rule
      if options[:unicode]
        VERTICAL_RULE
      else
        '|'
      end
    end

    def left_tee
      if options[:unicode]
        LEFT_TEE
      else
        '+'
      end
    end

    def horizontal_rule
      if options[:unicode]
        HORIZONTAL_RULE
      else
        '-'
      end
    end

    def single_cross
      if options[:unicode]
        SINGLE_CROSS
      else
        '+'
      end
    end

    def right_tee
      if options[:unicode]
        RIGHT_TEE
      else
        '+'
      end
    end

    def lower_left
      if options[:unicode]
        LOWER_LEFT
      else
        '+'
      end
    end

    def lower_right
      if options[:unicode]
        LOWER_RIGHT
      else
        '+'
      end
    end

    def lower_tee
      if options[:unicode]
        LOWER_TEE
      else
        '+'
      end
    end

    # Does this Formatter require a second pass over the cells to align the
    # columns according to the alignment formatting instruction to the width of
    # the widest cell in each column?
    def aligned?
      true
    end

    def pre_header(widths)
      result = upper_left
      widths.values.each do |w|
        result += double_rule * (w + 2) + upper_tee
      end
      result[-1] = upper_right
      result + "\n"
    end

    def pre_row
      vertical_rule
    end

    def pre_cell(_h)
      ''
    end

    def quote_cell(v)
      v
    end

    def post_cell
      ''
    end

    def inter_cell
      vertical_rule
    end

    def post_row
      vertical_rule + "\n"
    end

    def hline(widths)
      result = left_tee #"\u251C"
      widths.values.each do |w|
        result += horizontal_rule * (w + 2) + single_cross
      end
      result[-1] = right_tee
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

    def post_footers(widths)
      result = lower_left
      widths.values.each do |w|
        result += double_rule * (w + 2) + lower_tee
      end
      result[-1] = lower_right
      result + "\n"
    end
  end
end
