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
  # An entire column can be retrieved by header from a Table, thus,
  # #+BEGIN_EXAMPLE
  # tab = Table.new("example.org")
  # tab[:age].avg
  # #+END_EXAMPLE
  # will extract the entire ~:age~ column and compute its average, since Column
  # objects respond to aggregate methods, such as ~sum~, ~min~, ~max~, and ~avg~.
  class Table
    attr_reader :columns, :footer

    TYPES = %w(NilClass TrueClass FalseClass Date DateTime Numeric String)

    def initialize(input = nil, ext = '.csv')
      @columns = []
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

    # Return the column with the given header.
    def column(key)
      columns.detect { |c| c.header == key.as_sym }
    end

    # Return the array of items of the column with the given header.
    def [](key)
      column(key)
    end

    def column?(key)
      headers.include?(key.as_sym)
    end

    # Attr_reader as a plural
    def types
      columns.map(&:type)
    end

    # Return the headers for the table as an array of symbols.
    def headers
      columns.map(&:header)
    end

    # Return the rows of the table as an array of hashes, keyed by the headers.
    def rows
      rows = []
      0.upto(columns.first.items.last_i) do |rnum|
        row = {}
        columns.each do |col|
          row[col.header] = col[rnum]
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
      result = Table.new
      columns.each_with_index do |col, k|
        result.add_column(col + other.columns[k])
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
        columns << Column.new(header: k) unless column?(k)
        column(key) << v
      end
      self
    end

    def add_column(col)
      raise "Table already has a column with header '#{col.header}'" if column?(col.header)
      columns << col
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
  end
end
