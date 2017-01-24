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

    def empty?
      rows.empty?
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

    # Return a Table having the selected column expression. Each expression can
    # be either a (1) symbol, (2) a hash of symbol => symbol, or (3) a hash of
    # symbol => 'string', though the bare symbol arguments (1) must precede any
    # hash arguments. Each expression results in a column in the resulting Table
    # in the order given. The expressions are evaluated in order as well.
    def select(*exps)
      new_cols = {}
      new_heads = []
      exps.each do |exp|
        case exp
        when Symbol, String
          h = exp.as_sym
          raise "Header #{h} does not exist" unless headers.include?(h)
          new_heads << h
          new_cols[h] = Column.new(header: h,
                                   type: column(h).type,
                                   items: column(h).items)
        when Hash
          exp.each_pair do |key, xp|
            case xp
            when Symbol
              h = xp.as_sym
              raise "Header #{key} does not exist" unless column?(key)
              new_heads << h
              new_cols[h] = Column.new(header: h,
                                       type: column(key).type,
                                       items: column(key).items)
            when String
              # Evaluate xp in the context of a binding including a local
              # variable for each original column with the name as the head and
              # the value for the current row as the value and a local variable
              # for each new column with the new name and the new value.
              h = key.as_sym
              new_heads << h
              new_cols[h] = Column.new(header: h)
              ev = Evaluator.new(vars: { row: 0 }, before: '@row += 1')
              rows.each_with_index do |old_row, row_num|
                new_row ||= {}
                # Gather the new values computed so far for this row
                new_vars = new_heads.zip(new_cols.keys
                                           .map { |k| new_cols[k] }
                                           .map { |c| c[row_num] })
                vars = old_row.merge(Hash[new_vars])
                # Now we have a hash, vars, of all local variables we want to be
                # defined while evaluating expression xp as the value of column
                # key in the new column.
                new_row[h] = ev.evaluate(xp, vars: vars)
                new_cols[h] << new_row[h]
              end
            else
              raise 'Hash parameters to select must be a symbol or string'
            end
          end
        else
          raise 'Parameters to select must be a symbol, string, or hash'
        end
      end
      result = Table.new
      new_heads.each do |h|
        result.add_column(new_cols[h])
      end
      result
    end

    # Return a Table containing only rows matching the where expression.
    def where(expr)
      expr = expr.to_s
      result = Table.new
      ev = Evaluator.new(vars: { row: 0 }, before: '@row += 1')
      rows.each do |row|
        result.add_row(row) if ev.evaluate(expr, vars: row)
      end
      result
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

    # Return a Table in which all rows of the table are divided into groups
    # where the value of all columns named as simple symbols are equal. All
    # other columns are set to the result of aggregating the values of that
    # column within the group according to the Column aggregate function (:sum,
    # :min, :max, etc.) set in a hash parameter with the non-aggregate column
    # name as a key and the symbol for the aggregate function as a value. For
    # example, consider the following call:
    #
    # #+BEGIN_EXAMPLE
    # tab.group_by(:date, :code, :price, shares: :sum, ).
    # #+END_EXAMPLE
    #
    # The first three parameters are simple symbols, so the table is divided
    # into groups of rows in which the value of :date, :code, and :price are
    # equal. The :shares parameter is set to the aggregate function :sum, so it
    # will appear in the result as the sum of all the :shares values in each
    # group. Any non-aggregate columns that have no aggregate function set
    # default to using the aggregate function :first. Note that because of the
    # way Ruby parses parameters to a method call, all the grouping symbols must
    # appear first in the parameter list.
    def group_by(*exprs)
      group_cols = []
      agg_cols = {}
      exprs.each do |xp|
        case xp
        when Symbol
          group_cols << xp
        when Hash
          agg_cols = xp
        else
          raise "Cannot group by parameter '#{xp}"
        end
      end
      default_agg_func = :first
      default_cols = headers - group_cols - agg_cols.keys
      default_cols.each do |h|
        agg_cols[h] = default_agg_func
      end

      sorted_tab = order_by(group_cols)
      groups = sorted_tab.rows.group_by do |r|
        group_cols.map { |k| r[k] }
      end
      result_rows = []
      groups.each_pair do |_vals, grp_rows|
        result_rows << row_from_group(grp_rows, group_cols, agg_cols)
      end
      result = Table.new
      result_rows.each do |row|
        result.add_row(row)
      end
      result
    end

    private

    def row_from_group(rows, grp_cols, agg_cols)
      new_row = {}
      grp_cols.each do |h|
        new_row[h] = rows.first[h]
      end
      agg_cols.each_pair do |h, agg_func|
        items = rows.map { |r| r[h] }
        new_h = "#{agg_func}_#{h}"
        new_row[new_h] = Column.new(header: h,
                                items: items,
                                type: column(h).type).send(agg_func)
      end
      new_row
    end

    ############################################################################
    # Table output methods.
    ############################################################################

    public

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

    def <<(row)
      add_row(row)
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
