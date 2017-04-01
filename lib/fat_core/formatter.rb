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
    LOCATIONS = [:header, :body, :bfirst, :gfirst, :gfooter, :footer].freeze

    attr_reader :table, :format_at, :footers, :gfooters

    class_attribute :default_format
    self.default_format = {
      nil_text: '',
      case: :none,
      alignment: :left,
      bold: false,
      italic: false,
      color: 'black',
      hms: false,
      pre_digits: -1,
      post_digits: -1,
      commas: false,
      currency: false,
      datetime_fmt: '%F %H:%M:%S',
      date_fmt: '%F',
      true_text: 'T',
      false_text: 'F',
      true_color: 'black',
      false_color: 'black'
    }

    @@currency_symbol = '$'

    def self.currency_symbol=(char)
      @@currency_symbol = char.to_s
    end

    def self.currency_symbol
      @@currency_symbol
    end

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
    #   + d[fmt] :: apply the format to a datetime that has no or zero hour,
    #        minute, second components, where fmt is a valid format string for
    #        Date#strftime, otherwise, the datetime will be formatted as an ISO
    #        8601 string, YYYY-MM-DD.
    #   + D[fmt] :: apply the format to a datetime that has at least a non-zero
    #        hour component where fmt is a valid format string for
    #        Date#strftime, otherwise, the datetime will be formatted as an ISO
    #        8601 string, YYYY-MM-DD.
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
    def initialize(table = Table.new)
      unless table && table.is_a?(Table)
        raise ArgumentError, 'must initialize Formatter with a Table'
      end
      @table = table
      @footers = {}
      @gfooters = {}
      # Formatting instructions for various "locations" within the Table, as
      # a hash of hashes.  The outer hash is keyed on the location, and each
      # inner hash is keyed on either a column sym or a type sym, :string, :numeric,
      # :datetime, :boolean, or :nil.  The value of the inner hashes are
      # OpenStruct structs.
      @format_at = {}
      [:header, :bfirst, :gfirst, :body, :footer, :gfooter].each do |loc|
        @format_at[loc] = {}
        table.headers.each do |h|
          format_at[loc][h] = OpenStruct.new(self.class.default_format)
        end
      end
      yield self if block_given?
    end

    ############################################################################
    # Footer methods
    #
    #
    # A Table may have any number of footers and any number of group footers.
    # Footers are not part of the table's data and never participate in any of
    # the transformation methods on tables.  They are never inherited by output
    # tables from input tables in any of the transformation methods.
    #
    # When output, a table footer will appear at the bottom of the table, and a
    # group footer will appear at the bottom of each group.
    #
    # Each footer must have a label, usually a string such as 'Total', to
    # identify the purpose of the footer, and the label must be distinct among
    # all footers of the same type. That is you may have a table footer labeled
    # 'Total' and a group footer labeled 'Total', but you may not have two table
    # footers with that label.  If the first column of the table is not included
    # in the footer, the footer's label will be placed there, otherwise, there
    # will be no label output.  The footers are accessible with the #footers
    # method, which returns a hash indexed by the label converted to a symbol.
    # The symbol is reconverted to a title-cased string on output.
    #
    # Note that by adding footers or gfooters to the table, you are only stating
    # what footers you want on output of the table.  No actual calculation is
    # performed until the table is output.
    #
    ############################################################################

    public

    # Add a table footer to the table with a label given in the first parameter,
    # defaulting to 'Total'.  After the label, you can given any number of
    # headers (as symbols) for columns to be summed, and then any number of hash
    # parameters for columns for with to apply an aggregate other than :sum.
    # For example, these are valid footer definitions.
    #
    # # Just sum the shares column with a label of 'Total'
    # tab.footer(:shares)
    #
    # # Change the label and sum the :price column as well
    # tab.footer('Grand Total', :shares, :price)
    #
    # # Average then show standard deviation of several columns
    # tab.footer.('Average', date: avg, shares: :avg, price: avg)
    # tab.footer.('Sigma', date: dev, shares: :dev, price: :dev)
    #
    # # Do some sums and some other aggregates: sum shares, average date and
    # # price.
    # tab.footer.('Summary', :shares, date: avg, price: avg)
    def footer(label, *sum_cols, **agg_cols)
      label = label.to_s
      foot = {}
      sum_cols.each do |h|
        unless table.headers.include?(h)
          raise "No '#{h}' column in table to sum in the footer"
        end
        foot[h] = :sum
      end
      agg_cols.each do |h, agg|
        unless table.headers.include?(h)
          raise "No '#{h}' column in table to #{aggregate} in the footer"
        end
        foot[h] = agg
      end
      @footers[label] = foot
      self
    end

    def gfooter(label, *sum_cols, **agg_cols)
      label = label.to_s
      foot = {}
      sum_cols.each do |h|
        unless table.headers.include?(h)
          raise "No '#{h}' column in table to sum in the group footer"
        end
        foot[h] = :sum
      end
      agg_cols.each do |h, agg|
        unless table.headers.include?(h)
          raise "No '#{h}' column in table to #{aggregate} in the group footer"
        end
        foot[h] = agg
      end
      @gfooters[label] = foot
      self
    end

    def sum_footer(*cols)
      footer('Total', *cols)
    end

    def sum_gfooter(*cols)
      gfooter('Group Total', *cols)
    end

    def avg_footer(*cols)
      hsh = {}
      cols.each do |c|
        hsh[c] = :avg
      end
      footer('Average', hsh)
    end

    def avg_gfooter(*cols)
      hsh = {}
      cols.each do |c|
        hsh[c] = :avg
      end
      gfooter('Group Average', hsh)
    end

    def min_footer(*cols)
      hsh = {}
      cols.each do |c|
        hsh[c] = :min
      end
      footer('Minimum', hsh)
    end

    def min_gfooter(*cols)
      hsh = {}
      cols.each do |c|
        hsh[c] = :min
      end
      gfooter('Group Minimum', hsh)
    end

    def max_footer(*cols)
      hsh = {}
      cols.each do |c|
        hsh[c] = :max
      end
      footer('Maximum', hsh)
    end

    def max_gfooter(*cols)
      hsh = {}
      cols.each do |c|
        hsh[c] = :max
      end
      gfooter('Group Maximum', hsh)
    end

    ############################################################################
    # Formatting methods
    ############################################################################

    # Define formats for all locations
    def format(**fmts)
      [:header, :bfirst, :gfirst, :body, :footer, :gfooter].each do |loc|
        format_for(loc, fmts)
      end
    end

    # Define a format for the given location, :header, :body, :footer, :gfooter
    # (the group footers), :bfirst (the first row in the table body), or :gfirst
    # (the first rows in group bodies). Formats are specified with hash
    # arguments where the keys are either (1) the name of a table column in
    # symbol form, or (2) the name of a column type, i.e., :string, :numeric, or
    # :datetime, :boolean, or :nil (for empty cells or untyped columns). The
    # value given for the hash arguments should be strings that contain
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
      @format_at[location] ||= {}
      table.headers.each do |h|
        typ = table.type(h).as_sym
        format_h = default_format.dup
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
        format_at[location][h] = OpenStruct.new(format_h)
      end
      self
    end

    private

    ###############################################################################
    # Parsing and validation routines
    ###############################################################################

    # Return a hash that reflects the formatting instructions given in the
    # string fmt. Raise an error if it contains invalid formatting instructions.
    # If fmt contains conflicting instructions, say C and L, there is no
    # guarantee which will win, but it will not be considered an error to do so.
    def parse_string_fmt(fmt)
      format, fmt = parse_str_fmt(fmt)
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
      fmt_hash = {}
      fmt_hash[:color] = 'black'
      if fmt =~ /c\[([-_a-zA-Z]+)\]/
        fmt_hash[:color] = $1
        fmt = fmt.sub($&, '')
      end
      fmt_hash[:case] = :none
      if fmt =~ /u/
        fmt_hash[:case] = :lower
        fmt = fmt.sub($&, '')
      end
      if fmt =~ /U/
        fmt_hash[:case] = :upper
        fmt = fmt.sub($&, '')
      end
      if fmt =~ /t/
        fmt_hash[:case] = :title
        fmt = fmt.sub($&, '')
      end
      fmt_hash[:bold] = false
      if fmt =~ /B/
        fmt_hash[:bold] = true
        fmt = fmt.sub($&, '')
      end
      fmt_hash[:italic] = false
      if fmt =~ /I/
        fmt_hash[:italic] = true
        fmt = fmt.sub($&, '')
      end
      fmt_hash[:alignment] = :left
      if fmt =~ /R/
        fmt_hash[:alignment] = :right
        fmt = fmt.sub($&, '')
      end
      if fmt =~ /C/
        fmt_hash[:alignment] = :center
        fmt = fmt.sub($&, '')
      end
      if fmt =~ /L/
        fmt_hash[:alignment] = :left
        fmt = fmt.sub($&, '')
      end
      [fmt_hash, fmt]
    end

    # Utility method that extracts nil instructions and returns a hash of the
    # instructions and the unconsumed part of the instruction string. This is
    # called to cull nil-based instructions from a formatting string intended
    # for other types, such as numeric, etc.
    def parse_nil_fmt(fmt)
      # We parse the more complex formatting constructs first, and after each
      # parse, we remove the matched construct from fmt.  At the end, any
      # remaining characters in fmt should be invalid.
      fmt_hash = {}
      fmt_hash[:nil_text] = ''
      if fmt =~ /n\[\s*([^\]]*)\s*\]/
        fmt_hash[:nil_text] = $1.clean
        fmt = fmt.sub($&, '')
      end
      [fmt_hash, fmt]
    end

    # Return a hash that reflects the numeric or string formatting instructions
    # given in the string fmt. Raise an error if it contains invalid formatting
    # instructions. If fmt contains conflicting instructions, there is no
    # guarantee which will win, but it will not be considered an error to do so.
    def parse_numeric_fmt(fmt)
      # We parse the more complex formatting constructs first, and after each
      # parse, we remove the matched construct from fmt.  At the end, any
      # remaining characters in fmt should be invalid.
      fmt_hash, fmt = parse_str_fmt(fmt)
      fmt = fmt.gsub(/\s+/, '')
      fmt_hash[:pre_digits] = -1
      fmt_hash[:post_digits] = -1
      if fmt =~ /(\d+).(\d+)/
        fmt_hash[:pre_digits] = $1.to_i
        fmt_hash[:post_digits] = $2.to_i
        fmt = fmt.sub($&, '')
      end
      fmt_hash[:commas] = false
      if fmt =~ /,/
        fmt_hash[:commas] = true
        fmt = fmt.sub($&, '')
      end
      fmt_hash[:currency] = false
      if fmt =~ /\$/
        fmt_hash[:currency] = true
        fmt = fmt.sub($&, '')
      end
      fmt_hash[:hms] = false
      if fmt =~ /H/
        fmt_hash[:hms] = true
        fmt = fmt.sub($&, '')
      end
      unless fmt.blank?
        raise ArgumentError, "unrecognized numeric formatting instructions '#{fmt}'"
      end
      fmt_hash
    end

    # Return a hash that reflects the datetime or string formatting instructions
    # given in the string fmt. Raise an error if it contains invalid formatting
    # instructions. If fmt contains conflicting instructions, there is no
    # guarantee which will win, but it will not be considered an error to do so.
    def parse_datetime_fmt(fmt)
      # We parse the more complex formatting constructs first, and after each
      # parse, we remove the matched construct from fmt.  At the end, any
      # remaining characters in fmt should be invalid.
      fmt_hash, fmt = parse_str_fmt(fmt)
      fmt = fmt.gsub(/\s+/, '')
      fmt_hash[:date_fmt] = '%F'
      if fmt =~ /d\[([^\]]*)\]/
        fmt_hash[:date_fmt] = $1
        fmt = fmt.sub($&, '')
      end
      fmt_hash[:datetime_fmt] = '%F %H:%M:%S',
      if fmt =~ /D\[([^\]]*)\]/
        fmt_hash[:date_fmt] = $1
        fmt = fmt.sub($&, '')
      end
      unless fmt.blank?
        raise ArgumentError, "unrecognized datetime formatting instructions '#{fmt}'"
      end
      fmt_hash
    end

    # Return a hash that reflects the boolean or string formatting instructions
    # given in the string fmt. Raise an error if it contains invalid formatting
    # instructions. If fmt contains conflicting instructions, there is no
    # guarantee which will win, but it will not be considered an error to do so.
    def parse_boolean_fmt(fmt)
      # We parse the more complex formatting constructs first, and after each
      # parse, we remove the matched construct from fmt.  At the end, any
      # remaining characters in fmt should be invalid.
      fmt_hash, fmt = parse_str_fmt(fmt)
      fmt_hash[:true_text] = 'T'
      fmt_hash[:false_text] = 'F'
      if fmt =~ /b\[\s*([^\],]*),([^\]]*)\s*\]/
        fmt_hash[:true_text] = $1.clean
        fmt_hash[:false_text] = $2.clean
        fmt = fmt.sub($&, '')
      end
      # Since true_text, false_text and nil_text may want to have internal
      # spaces, defer removing extraneous spaces until after they are parsed.
      fmt = fmt.gsub(/\s+/, '')
      fmt_hash[:true_color] = 'black'
      fmt_hash[:false_color] = 'black'
      if fmt =~ /c\[([-_a-zA-Z]+),([-_a-zA-Z]+)\]/
        fmt_hash[:true_color] = $1
        fmt_hash[:false_color] = $2
        fmt = fmt.sub($&, '')
      end
      if fmt =~ /Y/
        fmt_hash[:true_text] = 'Y'
        fmt_hash[:false_text] = 'N'
        fmt = fmt.sub($&, '')
      end
      if fmt =~ /T/
        fmt_hash[:true_text] = 'T'
        fmt_hash[:false_text] = 'F'
        fmt = fmt.sub($&, '')
      end
      if fmt =~ /X/
        fmt_hash[:true_text] = 'X'
        fmt_hash[:false_text] = ''
        fmt = fmt.sub($&, '')
      end
      unless fmt.blank?
        raise ArgumentError, "unrecognized boolean formatting instructions '#{fmt}'"
      end
      fmt_hash
    end

    ###############################################################################
    # Applying formatting
    ###############################################################################

    public

    def format_cell(val, istruct, width = nil)
      case val
      when Numeric
        str = format_numeric(val, istruct)
        format_string(str, istruct, width)
      when DateTime, Date
        str = format_datetime(val, istruct)
        format_string(str, istruct, width)
      when TrueClass, FalseClass
        str = format_boolean(val, istruct)
        format_string(str, istruct, width)
      when NilClass
        str = istruct.nil_text
        format_string(str, istruct, width)
      when String
        format_string(val, istruct, width)
      else
        raise ArgumentError,
              "cannot format value '#{val}' of class #{val.class}"
      end
    end

    private

    # Convert a boolean to a string according to instructions in istruct, which
    # is assumed to be the result of parsing a formatting instruction string as
    # above. Only device-independent formatting is done here. Device dependent
    # formatting (e.g., color) can be done in a subclass of Formatter by
    # specializing this method.
    def format_boolean(val, istruct)
      return istruct.nil_text if val.nil?
      val ? istruct.true_text : istruct.false_text
    end

    # Convert a datetime to a string according to instructions in istruct, which
    # is assumed to be the result of parsing a formatting instruction string as
    # above. Only device-independent formatting is done here. Device dependent
    # formatting (e.g., color) can be done in a subclass of Formatter by
    # specializing this method.
    def format_datetime(val, istruct)
      return istruct.nil_text if val.nil?
      if val.to_date == val
        # It is a Date, with no time component.
        val.strftime(istruct.date_fmt)
      else
        val.strftime(istruct.datetime_fmt)
      end
    end

    # Convert a numeric to a string according to instructions in istruct, which
    # is assumed to be the result of parsing a formatting instruction string as
    # above. Only device-independent formatting is done here. Device dependent
    # formatting (e.g., color) can be done in a subclass of Formatter by
    # specializing this method.
    def format_numeric(val, istruct)
      return istruct.nil_text if val.nil?
      val = val.round(istruct.post_digits) if istruct.post_digits >= 0
      if istruct.hms
        result = val.secs_to_hms
        istruct.commas = false
      elsif istruct.currency
        prec = istruct.post_digits == -1 ? 2 : istruct.post_digits
        delim = istruct.commas ? ',' : ''
        result = val.to_s(:currency, precision: prec, delimiter: delim,
                                    unit: Formatter.currency_symbol)
        istruct.commas = false
      elsif istruct.pre_digits.positive?
        if val.whole?
          # No fractional part, ignore post_digits
          result = sprintf("%0#{istruct.pre_digits}d", val)
        elsif istruct.post_digits >= 0
          # There's a fractional part and pre_digits.  sprintf width includes
          # space for fractional part and decimal point, so add pre, post, and 1
          # to get the proper sprintf width.
          wid = istruct.pre_digits + 1 + istruct.post_digits
          result = sprintf("%0#{wid}.#{istruct.post_digits}f", val)
        else
          val = val.round(0)
          result = sprintf("%0#{istruct.pre_digits}d", val)
        end
      elsif istruct.post_digits >= 0
        # Round to post_digits but no padding of whole number, pad fraction with
        # trailing zeroes.
        result = sprintf("%.#{istruct.post_digits}f", val)
      else
        result = val.to_s
      end
      if istruct.commas
        # Commify the whole number part if not done already.
        result = result.commify
      end
      result
    end

    # Apply non-device-dependent string formatting instructions.
    def format_string(val, istruct, width = nil)
      val = istruct.nil_text if val.nil?
      val =
        case istruct.case
        when :lower
          val.downcase
        when :upper
          val.upcase
        when :title
          val.entitle
        when :none
          val
        end
      if width && aligned?
        pad = width - width(val)
        case istruct.alignment
        when :left
          val += ' ' * pad
        when :right
          val = ' ' * pad + val
        when :center
          lpad = pad / 2 + (pad.odd? ? 1 : 0)
          rpad = pad / 2
          val = ' ' * lpad + val + ' ' * rpad
        else
          val = val
        end
      end
      val
    end

    ###############################################################################
    # Output routines
    ###############################################################################

    public

    def output
      # Build the output as an array of row hashes, with the hashes keyed on the
      # new header string and the values the string-formatted cells. Each group
      # boundary, gfooter, and footer is marked by inserting a nil in the result
      # array at that point.
      formatted_headers = build_formatted_headers
      new_rows = build_formatted_body
      new_rows += build_formatted_footers

      # Make a second pass over the formatted cells to add spacing according to
      # the alignment instruction if this is a Formatter that performs its own
      # alignment.
      if aligned?
        widths = width_map(formatted_headers, new_rows)
        table.headers.each do |h|
          formatted_headers[h] =
            format_string(formatted_headers[h], format_at[:header][h], widths[h])
        end
        aligned_rows = []
        new_rows.each do |loc_row|
          if loc_row.nil?
            aligned_rows << nil
            next
          end
          loc, row = *loc_row
          aligned_row = {}
          row.each_pair do |h, val|
            aligned_row[h] = format_string(val, format_at[loc][h], widths[h])
          end
          aligned_rows << [loc, aligned_row]
        end
        new_rows = aligned_rows
      end

      # Now that the contents of the output table cells have been computed and
      # alignment applied, we can actually construct the table using the methods
      # for constructing table parts, pre_table, etc. We expect that these will
      # be overridden by subclasses of Formatter for specific output targets. In
      # any event, the result is a single string representing the table in the
      # syntax of the output target.
      result = ''
      result += pre_table
      if include_header_row?
        result += pre_header(widths)
        result += pre_row
        cells = []
        formatted_headers.each_pair do |h, v|
          cells << pre_cell(h) + quote_cell(v) + post_cell
        end
        result += cells.join(inter_cell)
        result += post_row
        result += post_header(widths)
      end
      new_rows.each do |loc_row|
        result += hline(widths) if loc_row.nil?
        next if loc_row.nil?
        _loc, row = *loc_row
        result += pre_row
        cells = []
        row.each_pair do |h, v|
          cells << pre_cell(h) + quote_cell(v) + post_cell
        end
        result += cells.join(inter_cell)
        result += post_row
      end
      result += post_table
      evaluate? ? eval(result) : result
    end

    private

    # Return a hash mapping the table's headers to their formatted versions. If
    # a hash of column widths is given, perform alignment within the given field
    # widths.
    def build_formatted_headers(widths = {})
      map = {}
      table.headers.each do |h|
        map[h] = format_string(h.as_string, format_at[:header][h], widths[h])
      end
      map
    end

    # Return an array of two-element arrays, with the first element of the
    # inner array being the location of the row and the second element being a
    # hash, using the table's headers as keys and the formatted cells as the
    # values. Add formatted group footers along the way.
    def build_formatted_body
      new_rows = []
      tbl_row_k = 0
      table.groups.each_with_index do |grp, grp_k|
        # Mark the beginning of a group if this is the first group after the
        # header or the second or later group.
        new_rows << nil if include_header_row? || grp_k.positive?
        # Compute group body
        grp_col = {}
        grp.each_with_index do |row, grp_row_k|
          new_row = {}
          location =
            if tbl_row_k.zero?
              :bfirst
            elsif grp_row_k.zero?
              :gfirst
            else
              :body
            end
          table.headers.each do |h|
            grp_col[h] ||= Column.new(header: h)
            grp_col[h] << row[h]
            new_row[h] = format_cell(row[h], format_at[location][h])
          end
          new_rows << [location, new_row]
          tbl_row_k += 1
        end
        # Compute group footers
        gfooters.each_pair do |label, gfooter|
          # Mark the beginning of a group footer
          new_rows << nil
          gfoot_row = {}
          first_h = nil
          grp_col.each_pair do |h, col|
            first_h ||= h
            gfoot_row[h] =
              if gfooter[h]
                format_cell(col.send(gfooter[h]), format_at[:gfooter][h])
              else
                ''
              end
          end
          if gfoot_row[first_h].blank?
            gfoot_row[first_h] = format_string(label, format_at[:gfooter][first_h])
          end
          new_rows << [:gfooter, gfoot_row]
        end
      end
      new_rows
    end

    def build_formatted_footers
      new_rows = []
      # Done with body, compute the table footers.
      footers.each_pair do |label, footer|
        # Mark the beginning of a footer
        new_rows << nil
        foot_row = {}
        first_h = nil
        table.columns.each do |col|
          h = col.header
          first_h ||= h
          foot_row[h] =
            if footer[h]
              format_cell(col.send(footer[h]), format_at[:footer][h])
            else
              ''
            end
        end
        # Put the label in the first column of footer unless it has been
        # formatted as part of footer.
        if foot_row[first_h].blank?
          foot_row[first_h] = format_string(label, format_at[:footer][first_h])
        end
        new_rows << [:footer, foot_row]
      end
      new_rows
    end

    # Return a hash of the maximum widths of all the given headers and rows.
    def width_map(formatted_headers, rows)
      widths = {}
      formatted_headers.each_pair do |h, v|
        widths[h] ||= 0
        widths[h] = [widths[h], width(v)].max
      end
      rows.each do |loc_row|
        next if loc_row.nil?
        _loc, row = *loc_row
        row.each_pair do |h, v|
          widths[h] ||= 0
          widths[h] = [widths[h], width(v)].max
        end
      end
      widths
    end

    # Does this Formatter require a second pass over the cells to align the
    # columns according to the alignment formatting instruction to the width of
    # the widest cell in each column?
    def aligned?
      false
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

    def pre_table
      ''
    end

    def post_table
      ''
    end

    def include_header_row?
      true
    end

    def pre_header(_widths)
      ''
    end

    def post_header(_widths)
      "\n"
    end

    def pre_row
      ''
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
      '|'
    end

    def post_row
      "\n"
    end

    def hline(_widths)
      ''
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
