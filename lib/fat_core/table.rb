module FatCore
  # A container for a two-dimensional table. All cells in the table must be a
  # String, a Date, a DateTime, a Bignum (or Integer), a BigDecimal, or a
  # boolean. All columns must be of one of those types or be a string
  # convertible into one of the supported types. It is considered an error if a
  # single column contains cells of different types. Any cell that cannot be
  # parsed as one of the numeric, date, or boolean types will have to_s applied
  #
  # You can initialize a Table in several ways:
  #
  # 1. with a Nil, which will return an empty table to which rows or columns can
  #    be added later,
  # 2. with the name of a .csv file,
  # 3. with the name of an .org file,
  # 4. with an IO or StringIO object for either type of file, but in that case,
  #    you need to specify 'csv' or 'org' as the second argument to tell it what
  #    kind of file format to expect,
  # 5. with an Array of Arrays,
  # 6. with an Array of Hashes, all having the same keys, which become the names
  #    of the column heads,
  # 7. with an Array of any objects that respond to .keys and .values methods,
  # 8. with another Table object.
  #
  # In the case of an array of arrays, if the second array's first element is a
  # string that looks like a rule separator, '-----------', '+----------', etc.,
  # the headers will be taken from the first array. In the case of an array of
  # Hashes or Hash-lime objects, the keys of the hashes will be used as the
  # headers. It is assumed that all the hashes have the same keys.
  #
  # In the resulting Table, the headers are converted into symbols, with all
  # spaces converted to underscore and everything down-cased. So, the heading,
  # 'Two Words' becomes the hash header :two_words.
  #
  # A table has footers kept as a hash of hashes.  The outer hash key
  # indicates what the footer represents, such as :total, or :average.  The
  # inner hash is a normal row-like hash keyed by the headers.
  class Table
    attr_reader :column, :type, :footer

    TYPES = %w(NilClass TrueClass FalseClass Date DateTime Numeric String)

    def initialize(input = nil, ext = '.csv')
      @column = {}
      @type = {}
      @footer = {}
      return self if input.nil?
      case input
      when IO, StringIO
        case ext
        when /csv/i
          from_csv(input)
        when /org/i
          from_org(input)
        else
          raise "Don't know how to read a '#{ext}' file."
        end
      when String
        ext = File.extname(input).downcase
        File.open(input, 'r') do |io|
          case ext
          when '.csv'
            from_csv(io)
          when '.org'
            from_org(io)
          else
            raise "Don't know how to read a '#{ext}' file."
          end
        end
      when Array
        case input[0]
        when Array
          from_array_of_arrays(input)
        when Hash
          from_array_of_hashes(input)
        when Table
          from_table(input)
        else
          raise ArgumentError,
                "Cannot initialize Table with an array of #{input[0].class}"
        end
      else
        raise ArgumentError,
              "Cannot initialize Table with #{input.class}"
      end
    end

    # Attr_reader as a plural
    def columns
      @column
    end

    # Attr_reader as a plural
    def types
      @type
    end

    # Return the headers for the table as an array of symbols.
    def headers
      column.keys
    end

    # Return the rows of the table as an array of hashes, keyed by the headers.
    def rows
      rows = []
      0.upto(columns.first.last.last_i) do |rnum|
        row = {}
        columns.each_pair do |k, v|
          row[k] = v[rnum]
        end
        rows << row
      end
      rows
    end

    ############################################################################
    # SQL look-alikes. The following methods are based on SQL equivalents and
    # all return a new Table object rather than modifying the table in place.
    ############################################################################

    # Return a new Table sorted on the rows of this Table on the possibly
    # multiple keys given in the array of syms in headers. Append a ! to the
    # symbol name to indicate reverse sorting on that column.
    def order_by(*sort_heads)
      sort_heads = [sort_heads].flatten
      rev_heads = sort_heads.select { |h| h.to_s.ends_with?('!') }
      sort_heads = sort_heads.map { |h| h.to_s.sub(/\!\z/, '').to_sym }
      rev_heads = rev_heads.map { |h| h.to_s.sub(/\!\z/, '').to_sym }
      new_rows = rows.sort do |r1, r2|
        key1 = sort_heads.map { |h| rev_heads.include?(h) ? r2[h] : r1[h] }
        key2 = sort_heads.map { |h| rev_heads.include?(h) ? r1[h] : r2[h] }
        key1 <=> key2
      end
      new_tab = Table.new
      new_rows.each do |nrow|
        new_tab.add_row(nrow)
      end
      new_tab
    end

    # Return a Table having the selected column expression. For example, ':date,
    # :ref', would return at Table with only those columns in that order. For
    # example, ':date > 2016-04-08'.
    def select(*exprs)
      tbl = Table.new
    end

    # Return a Table containing only rows matching the where expression.
    def where(*expr)
    end

    # Return a Table that combines this table with another table. The headers of
    # this table are used in the result. There must be the same number of
    # columns of the same type in the two tables, or an exception will be
    # thrown. Unlike in SQL, no duplicates are eliminated from the result.
    def union(other)
      unless columns.size == other.columns.size
        raise 'Cannot apply union to tables with a different number of columns.'
      end
      headers.each_with_index do |h, k|
        unless type[h] == other.type[other.headers[k]]
          raise 'Cannot apply union to tables with different column types'
        end
      end
      result = Table.new
      headers.each_with_index do |h, k|
        our_items = column[h].items
        their_items = other.column[other.headers[k]].items
        result.add_column(h, type[h], our_items + their_items)
      end
      result
    end

    def group_by
    end

    ############################################################################
    # Table output methods.
    ############################################################################

    # This returns the table as an Array of Arrays with formatting applied.
    # This would normally called after all calculations on the table are done
    # and you want to return the results.  The Array of Arrays structure is
    # what org-mode src blocks will render as an org table in the buffer.
    def to_org(formats: {})
      result = []
      header_row = []
      headers.each do |hdr|
        header_row << hdr.entitle
      end
      result << header_row
      # This causes org to place an hline under the header row
      result << nil unless header_row.empty?

      rows.each do |row|
        out_row = []
        headers.each do |hdr|
          out_row << row[hdr].to_s.format_by(formats[hdr])
        end
        result << out_row
      end
      result
    end

    ############################################################################
    # Table construction methods.
    ############################################################################

    # Add a row represented by a Hash having the headers as keys. All tables
    # should be built ultimately using this method as a primitive.
    def add_row(row)
      row.each_pair do |k, v|
        key = k.as_sym
        column[key] ||= Column.new
        val = convert_to_type(v, key)
        column[key] << val
      end
      self
    end

    def add_column(hdr, typ, items)
      hdr = hdr.as_sym
      typ = typ.to_s
      raise "Table already has a column with header '#{hdr}'" if column.key?(hdr)
      raise "Cannot add a column of unknown type '#{typ}'" unless TYPES.include?(typ)
      type[hdr] = typ
      # This may not be necessary since columns are presumably already typed.
      items = items.map { |i| convert_to_type(i, hdr) }
      column[hdr] = Column.new(items)
      self
    end

    private

    def from_array_of_hashes(rows)
      rows.each do |row|
        add_row(row)
      end
      self
    end

    def from_array_of_arrays(rows)
      headers = []
      if rows[0].any? { |itm| itm.to_s.number? }
        headers = (1..rows[0].size).to_a.map { |k| "col#{k}".as_sym }
        first_data_row = 0
      else
        # Use first row 0 as headers
        headers = rows[0].map(&:as_sym)
        first_data_row = 1
      end
      hrule_re = /\A\s*\|[-+]+/
      rows[first_data_row..-1].each do |row|
        next if row[0] =~ hrule_re
        row = row.map { |s| s.to_s.strip }
        hash_row = Hash[headers.zip(row)]
        add_row(hash_row)
      end
      self
    end

    def from_csv(io)
      ::CSV.new(io, headers: true, header_converters: :symbol,
                skip_blanks: true).each do |row|
        add_row(row.to_hash)
      end
      self
    end

    # Form rows of table by reading the first table found in the org file.
    def from_org(io)
      table_re = /\A\s*\|/
      hrule_re = /\A\s*\|[-+]+/
      rows = []
      table_found = false
      header_found = false
      io.each do |line|
        unless table_found
          # Skip through the file until a table is found
          next unless line =~ table_re
          table_found = true
        end
        break unless line =~ table_re
        if !header_found && line =~ hrule_re
          header_found = true
          next
        elsif header_found && line =~ hrule_re
          # Stop reading at the second hline
          break
        else
          line = line.sub(/\A\s*\|/, '').sub(/\|\s*\z/, '')
          rows << line.split('|')
        end
      end
      from_array_of_arrays(rows)
    end

    # Convert val to the type of key, a ruby class constant, such as Date,
    # Numeric, etc. If type is NilClass, the type is open, and a non-blank val
    # will attempt conversion to one of the allowed types, typing it as a String
    # if no other type is recognized. If the val is blank, and the type is nil,
    # the column type remains open. If the val is nil or a blank and the type is
    # already determined, the val is set to nil, and should be filtered from any
    # column computations. If the val is non-blank and the column type
    # determined, raise an error if the val cannot be converted to the column
    # type. Otherwise, returns the converted val as an object of the correct
    # class.
    def convert_to_type(val, key)
      case type[key].to_s
      when 'NilClass', ''
        if val.blank?
          # Leave the type of the column open
          val = nil
        else
          # Only non-blank values are allowed to set the type of the column
          val_class = val.class
          val = convert_to_boolean(val) ||
                convert_to_date_time(val) ||
                convert_to_numeric(val) ||
                convert_to_string(val)
          type[key] =
            if val.is_a?(Numeric)
              Numeric
            else
              val.class
            end
          val
        end
      when 'TrueClass', 'FalseClass'
        val_class = val.class
        val = convert_to_boolean(val)
        unless val
          raise "Inconsistent value in a Boolean column #{key} has class #{val_class}"
        end
        val
      when 'DateTime', 'Date'
        val_class = val.class
        val = convert_to_date_time(val)
        unless val
          raise "Inconsistent value in a DateTime column #{key} has class #{val_class}"
        end
        val
      when 'Numeric'
        val_class = val.class
        val = convert_to_numeric(val)
        unless val
          raise "Inconsistent value in a Numeric column #{key} has class #{val_class}"
        end
        val
      when 'String'
        val_class = val.class
        val = convert_to_string(val)
        unless val
          raise "Inconsistent value in a String column #{key} has class #{val_class}"
        end
        val
      else
        raise "Unknown object of class #{type[key]} in Table"
      end
    end

    # Convert the val to a boolean if it looks like one, otherwise return nil.
    # Any boolean or a string of t, f, true, false, y, n, yes, or no, regardless
    # of case is assumed to be a boolean.
    def convert_to_boolean(val)
      return val if val.is_a?(TrueClass) || val.is_a?(FalseClass)
      val = val.to_s.clean
      return nil if val.blank?
      if val =~ /\Afalse|f|n|no/i
        false
      elsif val =~ /\Atrue|t|y|yes\z/i
        true
      end
    end

    # Convert the val to a DateTime if it is either a DateTime, a Date, or a
    # String that can be parsed as a DateTime, otherwise return nil. It only
    # recognizes strings that contain a something like '2016-01-14' or
    # '2/12/1985' within them, otherwise DateTime.parse would treat many bare
    # numbers as dates, such as '2841381', which it would recognize as a valid
    # date, but the user probably does not intend it to be so treated.
    def convert_to_date_time(val)
      return val if val.is_a?(DateTime)
      return val.to_datetime if val.is_a?(Date)
      begin
        val = val.to_s.clean
        return nil if val.blank?
        return nil unless val =~ %r{\b\d\d\d\d[-/]\d\d?[-/]\d\d?\b}
        val = DateTime.parse(val.to_s.clean)
        val = val.to_date if val.seconds_since_midnight.zero?
        val
      rescue ArgumentError
        return nil
      end
    end

    # Convert the val to a Numeric if is already a Numberic or is a String that
    # looks like one. Any Float is promoted to a BigDecimal. Otherwise return
    # nil.
    def convert_to_numeric(val)
      return BigDecimal.new(val, Float::DIG) if val.is_a?(Float)
      return val if val.is_a?(Numeric)
      # Eliminate any commas, $'s, or _'s.
      val = val.to_s.clean.gsub(/[,_$]/, '')
      return nil if val.blank?
      case val
      when /\A(\d+\.\d*)|(\d*\.\d+)\z/
        BigDecimal.new(val.to_s.clean)
      when /\A[\d]+\z/
        val.to_i
      when %r{\A(\d+)\s*[:/]\s*(\d+)\z}
        Rational($1, $2)
      end
    end

    def convert_to_string(val)
      val.to_s
    end
  end
end
