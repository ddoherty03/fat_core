module FatCore
  ## A formatter is for use in Table output routines, and provides instructions
  ## for how the table ought to be formatted. The goal is to make subclasses of
  ## this class to handle different output targets, such as aoa for org tables,
  ## ansi terminals, LaTeX, html, plain text, org mode table text, and so forth.
  ## Many of the formatting options, such as color, will be no-ops for some
  ## output targets, such as text, but will be valid nonetheless. Thus, the
  ## Formatter subclass should provide the best implementation for each
  ## formatting request available for the target. This base class will consist
  ## largely of stub methods with implementations provided by the subclass.
  class Formatter
    attr_reader :table, :format

    LOCATIONS = [:header, :body, :bfirst, :gfirst, :gfooter, :footer].freeze

    # A Formatter can specify a hash to hold the formatting instructions for
    # columns by using the column head as a key and the value as the format
    # instructions.  In addition, the keys, :numeric, :string, :datetime,
    # :boolean, and :nil, can be used to specify the default format instructions
    # for columns of the given type is no other instructions have been given.
    #
    # Formatting instructions are strings, and what are valid strings depend on
    # the type of the column:
    #
    # - string :: for string columns, the following instructions are valid:
    #   + u :: convert the element to all lowercase,
    #   + U :: convert the element to all uppercase,
    #   + t :: title case the element, that is, upcase the initial letter in
    #        each word and lower case the other letters
    #   + B :: make the element bold
    #   + I :: make the element italic
    #   + R :: align the element on the right of the column
    #   + L :: align the element on the left of the column
    #   + C :: align the element in the center of the column
    #   + c[color] :: render the element in the given color
    # - numeric :: for a numeric, all the instructions valid for string are
    #      available, in addition to the following:
    #   + , :: insert grouping commas,
    #   + $ :: format the number as currency according to the locale,
    #   + m.n :: include at least m digits before the decimal point, padding on
    #        the left with zeroes as needed, and round the number to the n
    #        decimal places and include n digits after the decimal point,
    #        padding on the right with zeroes as needed,
    #   + H :: convert the number (assumed to be in units of seconds) to
    #        HH:MM:SS.ss form.  So a column that is the result of subtracting
    #        two :datetime forms will result in a :numeric expressed as seconds
    #        and can be displayed in hours, minutes, and seconds with this
    #        formatting instruction.
    # - datetime :: for a datetime, all the instructions valid for string are
    #      available, in addition to the following:
    #   + d[fmt] :: apply the format to the datetime where fmt is a valid format
    #        string for Date#strftime, otherwise, the datetime will be formatted
    #        as an ISO 8601 string, YYYY-MM-DD.
    # - boolean :: all the instructions valid for string are available, in
    #      addition to the following:
    #   + Y :: print true as 'Y' and false as 'N',
    #   + T :: print true as 'T' and false as 'F',
    #   + X :: print true as 'X' and false as '',
    #   + b[xxx,yyy] :: print true as the string given as xxx and false as the
    #        string given as yyy,
    #   + c[tcolor,fcolor] :: color a true element with tcolor and a false
    #        element with fcolor.
    # - nil :: by default, nil elements are rendered as blank cells, but you can
    #      make them visible with the following, and in that case, all the
    #      formatting instructions valid for strings are available:
    #   + n[niltext] :: render a nil item with the given text.
    #
    # In the foregoing, the earlier elements in each list will be available for
    # all formatter subclasses, while the later elements may or may not have any
    # effect on the output.
    #
    # The hashes that can be specified to the formatter determine the formatting
    # instructions for different parts of the output table:
    #
    # - header: :: instructions for the headers of the table,
    # - bfirst :: instructions for the first row in the body of the table,
    # - gfirst :: instructions for the cells in the first row of a group,
    # - body :: instructions for the cells in the body of the table, to the
    #      extent they are not governed by bfirst or gfirst.
    # - gfooter :: instructions for the cells of a group footer, and
    # - footer :: instructions for the cells of a footer.
    #
    def initialize(table)
      unless table && table.is_a?(Table)
        raise ArgumentError, 'must initialize Formatter with a Table'
      end
      @table = table
      # Formatting instructions for various "locations" within the Table, as
      # a hash of hashes.  The outer hash is keyed on the location, and each
      # inner hash is keyed on either a column sym or a type sym, :string, :numeric,
      # :datetime, :boolean, or :nil.  The value of the inner hashes are
      # OpenStruct structs.
      @format = {}
    end

    # Define a format for the given location, :header, :body, :footer, :gfooter
    # (the group footers), :bfirst (the first row in the table body), or :gfirst
    # (the first rows in group bodies). Formats are specified with hash
    # arguments where the keys are either (1) the name of a table column in
    # symbol form, or (2) the name of a column type, i.e., :string, :numeric, or
    # :datetime, :boolean, or :nilclass (for empty cells or untyped columns).
    # The value given for the hash arguments should be strings that contain
    # "instructions" on how elements of that column, or that type are to be
    # formatted on output. Formatting instructions for a column name take
    # precedence over those specified by type. And more specific locations take
    # precedence over less specific ones. For example, the first line of a table
    # is part of :body, :gfirst, and :bfirst, but since its identity as the
    # first row of the table is the most specific (there is only one of those,
    # there may be many rows that qualify as :gfirst, and even more that qualify
    # as :body rows). For purposes of formatting, all headers are considered of
    # the :string type. All empty cells are considered to be of the :nilclass
    # type. All other cells have the type of the column to which they belong,
    # including all cells in group or table footers.
    # def format_for(location, **fmts)
    #   unless LOCATIONS.include?(location)
    #     raise ArgumentError, "unknown format location '#{location}'"
    #   end
    #   valid_keys = table.headers + [:string, :numeric, :datetime, :boolean, :nil]
    #   invalid_keys = (fmts.keys - valid_keys).uniq
    #   unless invalid_keys.empty?
    #     msg = "invalid #{location} column or type: #{invalid_keys.join(',')}"
    #     raise ArgumentError, msg
    #   end
    #   @format[location] ||= {}
    #   table.headers.each do |h|
    #     @format[location][h] ||= parse_format('')
    #     if fmts[h]
    #       @format[location][h] = parse_format(fmts[h])
    #     elsif fmts.keys.include?(table.type(h).as_sym)
    #       @format[location][h] = parse_format(fmts[table.type(h).as_sym])
    #     end
    #     if fmts[:string]
    #       if fmts[h].blank?
    #         @format[location][h] = parse_format(fmts[:string])
    #       else
    #         # Header h has is own formatting, so merge string formatting onto it
    #         header_format = @format[location][h].to_h
    #         string_format = parse_format(fmts[:string]).to_h
    #         @format[location][h] = OpenStruct.new(string_format.merge(header_format))
    #       end
    #     end
    #     if fmts[:nil]
    #       binding.pry if h == :raw
    #       if fmts[h].blank? && fmts[table.type(h).as_sym].blank?
    #         @format[location][h] = parse_format(fmts[:nil])
    #       else
    #         nil_format = parse_format(fmts[:nil])
    #         @format[location][h].nil_text = nil_format.nil_text
    #       end
    #     end
    #   end
    #   self
    # end

    DEFAULT_FORMAT = {
      true_color: 'black',
      false_color: 'black',
      color: 'black',
      true_text: 'T',
      false_text: 'F',
      strftime_fmt: '%F',
      nil_text: '',
      pre_digits: -1,
      post_digits: -1,
      bold: false,
      italic: false,
      alignment: :left,
      commas: false,
      currency: false
    }.freeze

    def format_for(location, **fmts)
      unless LOCATIONS.include?(location)
        raise ArgumentError, "unknown format location '#{location}'"
      end
      valid_keys = table.headers + [:string, :numeric, :datetime, :boolean, :nil]
      invalid_keys = (fmts.keys - valid_keys).uniq
      unless invalid_keys.empty?
        msg = "invalid #{location} column or type: #{invalid_keys.join(',')}"
        raise ArgumentError, msg
      end
      @format[location] ||= {}
      table.headers.each do |h|
        typ = table.type(h).as_sym
        format_h = DEFAULT_FORMAT.dup
        parse_typ_method_name = 'parse_' + typ.to_s + '_fmt'
        if location == :header && fmts.keys.include?(:string)
          str_fmt = parse_string_fmt(fmts[:string])
          format_h = format_h.merge(str_fmt)
        end
        if location != :header && fmts.keys.include?(typ)
          typ_fmt = send(parse_typ_method_name, fmts[typ])
          format_h = format_h.merge(typ_fmt)
        end
        if location != :header && fmts.keys.include?(:string)
          typ_fmt = parse_string_fmt(fmts[:string])
          format_h = format_h.merge(typ_fmt)
        end
        if location != :header && fmts.keys.include?(:nil)
          typ_fmt = parse_nil_fmt(fmts[:nil]).first
          format_h = format_h.merge(typ_fmt)
        end
        if fmts[h]
          col_fmt = send(parse_typ_method_name, fmts[h])
          format_h = format_h.merge(col_fmt)
        end
        format[location][h] = OpenStruct.new(format_h)
      end
      self
    end

    # Return a hash that reflects the formatting instructions given in the
    # string fmt. Raise an error if it contains invalid formatting instructions.
    # If fmt contains conflicting instructions, say C and L, there is no
    # guarantee which will win, but it will not be considered an error to do so.
    def parse_string_fmt(fmt)
      #nil_format, fmt = parse_nil_fmt(fmt)
      format, fmt = parse_str_fmt(fmt)
      #format = format.merge(nil_format)
      unless fmt.blank?
        raise ArgumentError, "unrecognized string formatting instructions '#{fmt}'"
      end
      format
    end

    # Utility method that extracts string instructions and returns a hash for
    # of the instructions and the unconsumed part of the instruction string.
    # This is called to cull string-based instructions from a formatting string
    # intended for other types, such as numeric, etc.
    def parse_str_fmt(fmt)
      # We parse the more complex formatting constructs first, and after each
      # parse, we remove the matched construct from fmt.  At the end, any
      # remaining characters in fmt should be invalid.
      format = {}
      format[:color] = 'black'
      if fmt =~ /c\[([-_a-zA-Z]+)\]/
        format[:color] = $1
        fmt = fmt.sub($&, '')
      end
      format[:case] = :none
      if fmt =~ /u/
        format[:case] = :lower
        fmt = fmt.sub($&, '')
      end
      if fmt =~ /U/
        format[:case] = :upper
        fmt = fmt.sub($&, '')
      end
      if fmt =~ /t/
        format[:case] = :title
        fmt = fmt.sub($&, '')
      end
      format[:bold] = false
      if fmt =~ /B/
        format[:bold] = true
        fmt = fmt.sub($&, '')
      end
      format[:italic] = false
      if fmt =~ /I/
        format[:italic] = true
        fmt = fmt.sub($&, '')
      end
      format[:alignment] = :left
      if fmt =~ /R/
        format[:alignment] = :right
        fmt = fmt.sub($&, '')
      end
      if fmt =~ /C/
        format[:alignment] = :center
        fmt = fmt.sub($&, '')
      end
      if fmt =~ /L/
        format[:alignment] = :left
        fmt = fmt.sub($&, '')
      end
      [format, fmt]
    end

    # Utility method that extracts nil instructions and returns a hash of the
    # instructions and the unconsumed part of the instruction string. This is
    # called to cull nil-based instructions from a formatting string intended
    # for other types, such as numeric, etc.
    def parse_nil_fmt(fmt)
      # We parse the more complex formatting constructs first, and after each
      # parse, we remove the matched construct from fmt.  At the end, any
      # remaining characters in fmt should be invalid.
      format = {}
      format[:nil_text] = ''
      if fmt =~ /n\[\s*([^\]]*)\s*\]/
        format[:nil_text] = $1.clean
        fmt = fmt.sub($&, '')
      end
      [format, fmt]
    end

    # Return a hash that reflects the numeric or string formatting instructions
    # given in the string fmt. Raise an error if it contains invalid formatting
    # instructions. If fmt contains conflicting instructions, there is no
    # guarantee which will win, but it will not be considered an error to do so.
    def parse_numeric_fmt(fmt)
      # We parse the more complex formatting constructs first, and after each
      # parse, we remove the matched construct from fmt.  At the end, any
      # remaining characters in fmt should be invalid.
      format, fmt = parse_str_fmt(fmt)
      fmt = fmt.gsub(/\s+/, '')
      format[:pre_digits] = -1
      format[:post_digits] = -1
      if fmt =~ /(\d+).(\d+)/
        format[:pre_digits] = $1.to_i
        format[:post_digits] = $2.to_i
        fmt = fmt.sub($&, '')
      end
      format[:commas] = false
      if fmt =~ /,/
        format[:commas] = true
        fmt = fmt.sub($&, '')
      end
      format[:currency] = false
      if fmt =~ /\$/
        format[:currency] = true
        fmt = fmt.sub($&, '')
      end
      unless fmt.blank?
        raise ArgumentError, "unrecognized numeric formatting instructions '#{fmt}'"
      end
      format
    end

    # Return a hash that reflects the datetime or string formatting instructions
    # given in the string fmt. Raise an error if it contains invalid formatting
    # instructions. If fmt contains conflicting instructions, there is no
    # guarantee which will win, but it will not be considered an error to do so.
    def parse_datetime_fmt(fmt)
      # We parse the more complex formatting constructs first, and after each
      # parse, we remove the matched construct from fmt.  At the end, any
      # remaining characters in fmt should be invalid.
      format, fmt = parse_str_fmt(fmt)
      fmt = fmt.gsub(/\s+/, '')
      format[:strftime_fmt] = '%F'
      if fmt =~ /d\[([^\]]*)\]/
        format[:strftime_fmt] = $1
        fmt = fmt.sub($&, '')
      end
      unless fmt.blank?
        raise ArgumentError, "unrecognized datetime formatting instructions '#{fmt}'"
      end
      format
    end

    # Return a hash that reflects the boolean or string formatting instructions
    # given in the string fmt. Raise an error if it contains invalid formatting
    # instructions. If fmt contains conflicting instructions, there is no
    # guarantee which will win, but it will not be considered an error to do so.
    def parse_boolean_fmt(fmt)
      # We parse the more complex formatting constructs first, and after each
      # parse, we remove the matched construct from fmt.  At the end, any
      # remaining characters in fmt should be invalid.
      format, fmt = parse_str_fmt(fmt)
      format[:true_text] = 'T'
      format[:false_text] = 'F'
      if fmt =~ /b\[\s*([^\],]*),([^\]]*)\s*\]/
        format[:true_text] = $1.clean
        format[:false_text] = $2.clean
        fmt = fmt.sub($&, '')
      end
      # Since true_text, false_text and nil_text may want to have internal
      # spaces, defer removing extraneous spaces until after they are parsed.
      fmt = fmt.gsub(/\s+/, '')
      format[:true_color] = 'black'
      format[:false_color] = 'black'
      if fmt =~ /c\[([-_a-zA-Z]+),([-_a-zA-Z]+)\]/
        format[:true_color] = $1
        format[:false_color] = $2
        fmt = fmt.sub($&, '')
      end
      if fmt =~ /Y/
        format[:true_text] = 'Y'
        format[:false_text] = 'N'
        fmt = fmt.sub($&, '')
      end
      if fmt =~ /T/
        format[:true_text] = 'T'
        format[:false_text] = 'F'
        fmt = fmt.sub($&, '')
      end
      if fmt =~ /X/
        format[:true_text] = 'X'
        format[:false_text] = ''
        fmt = fmt.sub($&, '')
      end
      unless fmt.blank?
        raise ArgumentError, "unrecognized boolean formatting instructions '#{fmt}'"
      end
      format
    end
  end
end
