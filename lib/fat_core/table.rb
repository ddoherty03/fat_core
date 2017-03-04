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
    attr_reader :columns, :footers

    TYPES = %w(NilClass TrueClass FalseClass Date DateTime Numeric String)

    def initialize(input = nil, ext = '.csv')
      @columns = []
      @footers = {}
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
          if input[0].respond_to?(:to_hash)
            from_array_of_hashes(input)
          else
            raise ArgumentError,
                  "Cannot initialize Table with an array of #{input[0].class}"
          end
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

    # Return the number of rows in the table.
    def size
      return 0 if columns.empty?
      columns.first.size
    end

    # Return whether this table is empty.
    def empty?
      size.zero?
    end

    # Return the rows of the table as an array of hashes, keyed by the headers.
    def rows
      rows = []
      unless columns.empty?
        0.upto(columns.first.items.last_i) do |rnum|
          row = {}
          columns.each do |col|
            row[col.header] = col[rnum]
          end
          rows << row
        end
      end
      rows
    end

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
        new_tab << nrow
      end
      new_tab
    end

    # Return a Table having the selected column expressions. Each expression can
    # be either a (1) symbol, (2) a hash of symbol => symbol, or (3) a hash of
    # symbol => 'string', though the bare symbol arguments (1) must precede any
    # hash arguments. Each expression results in a column in the resulting Table
    # in the order given. The expressions are evaluated in order as well.
    def select(*exps)
      result = Table.new
      new_cols = {}
      ev = Evaluator.new(vars: { row: 0 }, before: '@row += 1')
      rows.each do |old_row|
        new_heads = []
        new_row ||= {}
        exps.each do |exp|
          case exp
          when Symbol, String
            h = exp.as_sym
            raise "Column '#{h}' in select does not exist" unless column?(h)
            new_row[h] = old_row[h]
          when Hash
            # Note that when one of the exps is a Hash, it will contain an
            # output expression for each member of the Hash, so we have to loop
            # through them here.
            exp.each_pair do |key, val|
              # Gather the new values computed so far for this row
              vars = old_row.merge(new_row)
              case val
              when Symbol
                h = val.as_sym
                raise "Column '#{h}' in select does not exist" unless vars.keys.include?(h)
                new_row[key] = vars[h]
              when String
                # Now we have a hash, vars, of all local variables we want to be
                # defined while evaluating expression xp as the value of column
                # key in the new column.
                h = key.as_sym
                new_row[h] = ev.evaluate(val, vars: vars)
                # Don't add this column to new_heads until after the eval so it
                # does not shadow the existing value of row[h].
              else
                raise 'Hash parameters to select must be a symbol or string'
              end
            end
          else
            raise 'Parameters to select must be a symbol, string, or hash'
          end
        end
        result << new_row
      end
      result
    end

    # Return a Table containing only rows matching the where expression.
    def where(expr)
      expr = expr.to_s
      result = Table.new
      ev = Evaluator.new(vars: { row: 0 }, before: '@row += 1')
      rows.each do |row|
        result << row if ev.evaluate(expr, vars: row)
      end
      result
    end

    # Return this table with all duplicate rows eliminated.
    def distinct
      result = Table.new
      uniq_rows = rows.uniq
      uniq_rows.each do |row|
        result << row
      end
      result
    end

    def uniq
      distinct
    end

    # Return a Table that combines this table with another table. In other
    # words, return the union of this table with the other. The headers of this
    # table are used in the result. There must be the same number of columns of
    # the same type in the two tables, or an exception will be thrown.
    # Duplicates are eliminated from the result.
    def union(other)
      set_operation(other, :+, true)
    end

    # Return a Table that combines this table with another table. In other
    # words, return the union of this table with the other. The headers of this
    # table are used in the result. There must be the same number of columns of
    # the same type in the two tables, or an exception will be thrown.
    # Duplicates are not eliminated from the result.
    def union_all(other)
      set_operation(other, :+, false)
    end

    # Return a Table that includes the rows that appear in this table and in
    # another table. In other words, return the intersection of this table with
    # the other. The headers of this table are used in the result. There must be
    # the same number of columns of the same type in the two tables, or an
    # exception will be thrown. Duplicates are eliminated from the result.
    def intersect(other)
      set_operation(other, :intersect, true)
    end

    # Return a Table that includes the rows that appear in this table and in
    # another table. In other words, return the intersection of this table with
    # the other. The headers of this table are used in the result. There must be
    # the same number of columns of the same type in the two tables, or an
    # exception will be thrown. Duplicates are not eliminated from the result.
    def intersect_all(other)
      set_operation(other, :intersect, false)
    end

    # Return a Table that includes the rows of this table except for any rows
    # that are the same as those in another table. In other words, return the
    # set difference between this table an the other. The headers of this table
    # are used in the result. There must be the same number of columns of the
    # same type in the two tables, or an exception will be thrown. Duplicates
    # are eliminated from the result.
    def except(other)
      set_operation(other, :difference, true)
    end

    # Return a Table that includes the rows of this table except for any rows
    # that are the same as those in another table. In other words, return the
    # set difference between this table an the other. The headers of this table
    # are used in the result. There must be the same number of columns of the
    # same type in the two tables, or an exception will be thrown. Duplicates
    # are not eliminated from the result.
    def except_all(other)
      set_operation(other, :difference, false)
    end

    private

    # Apply the set operation given by op between this table and the other table
    # given in the first argument.  If distinct is true, eliminate duplicates
    # from the result.
    def set_operation(other, op = :+, distinct = true)
      unless columns.size == other.columns.size
        raise 'Cannot apply a set operation to tables with a different number of columns.'
      end
      unless columns.map(&:type) == other.columns.map(&:type)
        raise 'Cannot apply a set operation to tables with different column types.'
      end
      other_rows = other.rows.map { |r| r.replace_keys(headers) }
      result = Table.new
      new_rows = rows.send(op, other_rows)
      new_rows.each do |row|
        result << row
      end
      distinct ? result.distinct : result
    end

    public

    # Return a table that joins this table to another based on one or more join
    # expressions. There are several possibilities for the join expressions:
    #
    # 1. If no join expressions are given, the tables will be joined when all
    #    values with the same name in both tables have the same value, a
    #    "natural" join. However, if the join type is :cross, the join
    #    expression will be taken to be 'true'. Otherwise, if there are no
    #    common column names, an exception will be raised.
    #
    # 2. If the join expressions are one or more symbols, the join condition
    #    requires that the values of both tables are equal for all columns named
    #    by the symbols. A column that appears in both tables can be given
    #    without modification and will be assumed to require equality on that
    #    column. If an unmodified symbol is not a name that appears in both
    #    tables, an exception will be raised. Column names that are unique to
    #    the first table must have a '_a' appended to the column name and column
    #    names that are unique to the other table must have a '_b' appended to
    #    the column name. These disambiguated column names must come in pairs,
    #    one for the first table and one for the second, and they will imply a
    #    join condition that the columns must be equal on those columns. Several
    #    such symbol expressions will require that all such implied pairs are
    #    equal in order for the join condition to be met.
    #
    # 3. Finally, a string expression can be given that contains an arbitrary
    #    ruby expression that will be evaluated for truthiness. Within the
    #    string, all column names must be disambiguated with the '_a' or '_b'
    #    modifiers whether they are common to both tables or not.  The names of
    #    the columns in both tables (without the leading ':' for symbols) are
    #    available as variables within the expression.
    #
    # The join_type parameter specifies what sort of join is performed, :inner,
    # :left, :right, :full, or :cross. The default is an :inner join. The types
    # of joins are defined as follows where T1 means this table, the receiver,
    # and T2 means other. These descriptions are taken from the Postgresql
    # documentation.
    #
    # - :inner :: For each row R1 of T1, the joined table has a row for each row
    #      in T2 that satisfies the join condition with R1.
    #
    # - :left :: First, an inner join is performed. Then, for each row in T1
    #      that does not satisfy the join condition with any row in T2, a joined
    #      row is added with null values in columns of T2. Thus, the joined
    #      table always has at least one row for each row in T1.
    #
    # - :right :: First, an inner join is performed. Then, for each row in T2
    #      that does not satisfy the join condition with any row in T1, a joined
    #      row is added with null values in columns of T1. This is the converse
    #      of a left join: the result table will always have a row for each row
    #      in T2.
    #
    # - :full :: First, an inner join is performed. Then, for each row in T1
    #      that does not satisfy the join condition with any row in T2, a joined
    #      row is added with null values in columns of T2. Also, for each row of
    #      T2 that does not satisfy the join condition with any row in T1, a
    #      joined row with null values in the columns of T1 is added.
    #
    # -  :cross :: For every possible combination of rows from T1 and T2 (i.e.,
    #      a Cartesian product), the joined table will contain a row consisting
    #      of all columns in T1 followed by all columns in T2. If the tables
    #      have N and M rows respectively, the joined table will have N * M
    #      rows.
    #
    JOIN_TYPES = [:inner, :left, :right, :full, :cross]

    def join(other, *exps, join_type: :inner)
      raise ArgumentError, 'need other table as first argument to join' unless other.is_a?(Table)
      unless JOIN_TYPES.include?(join_type)
        raise ArgumentError, "join_type may only be: #{JOIN_TYPES.join(', ')}"
      end
      # These may be needed for outer joins.
      self_row_nils = headers.map { |h| [h, nil] }.to_h
      other_row_nils = other.headers.map { |h| [h, nil] }.to_h
      join_expression, other_common_heads = build_join_expression(exps, other, join_type)
      ev = Evaluator.new
      result = Table.new
      other_rows = other.rows
      other_row_matches = Array.new(other_rows.size, false)
      rows.each do |self_row|
        self_row_matched = false
        other_rows.each_with_index do |other_row, k|
          # Same as other_row, but with keys that are common with self and equal
          # in value, removed, so the output table need not repeat them.
          locals = build_locals_hash(row_a: self_row, row_b: other_row)
          matches = ev.evaluate(join_expression, vars: locals)
          next unless matches
          self_row_matched = other_row_matches[k] = true
          out_row = build_out_row(row_a: self_row, row_b: other_row,
                                  common_heads: other_common_heads,
                                  type: join_type)
          result << out_row
        end
        if join_type == :left || join_type == :full
          unless self_row_matched
            out_row = build_out_row(row_a: self_row, row_b: other_row_nils, type: join_type)
            result << out_row
          end
        end
      end
      if join_type == :right || join_type == :full
        other_rows.each_with_index do |other_row, k|
          unless other_row_matches[k]
            out_row = build_out_row(row_a: self_row_nils, row_b: other_row, type: join_type)
            result << out_row
          end
        end
      end
      result
    end

    def inner_join(other, *exps)
      join(other, *exps)
    end

    def left_join(other, *exps)
      join(other, *exps, join_type: :left)
    end

    def right_join(other, *exps)
      join(other, *exps, join_type: :right)
    end

    def full_join(other, *exps)
      join(other, *exps, join_type: :full)
    end

    def cross_join(other)
      join(other, join_type: :cross)
    end

    private

    # Return an output row appropriate to the given join type, including all the
    # keys of row_a, the non-common keys of row_b for an :inner join, or all the
    # keys of row_b for other joins.  If any of the row_b keys are also row_a
    # keys, change the key name by appending a '_b' so the keys will not repeat.
    def build_out_row(row_a:, row_b:, common_heads: [], type: :inner)
      if type == :inner
        # Eliminate the keys that are common with row_a and were matched for
        # equality
        row_b = row_b.reject { |k, _| common_heads.include?(k) }
      end
      # Translate any remaining row_b heads to append '_b' if they have the
      # same name as a row_a key.
      a_heads = row_a.keys
      row_b = row_b.to_a.each.map do |k, v|
        [a_heads.include?(k) ? "#{k}_b".to_sym : k, v]
      end.to_h
      row_a.merge(row_b)
    end

    # Return a hash for the local variables of a join expression in which all
    # the keys in row_a have an '_a' appended and all the keys in row_b have a
    # '_b' appended.
    def build_locals_hash(row_a:, row_b:)
      row_a = row_a.to_a.each.map { |k, v| ["#{k}_a".to_sym, v] }.to_h
      row_b = row_b.to_a.each.map { |k, v| ["#{k}_b".to_sym, v] }.to_h
      row_a.merge(row_b)
    end

    # Return an array of two elements: (1) a ruby expression that expresses the
    # AND of all join conditions as described in the comment to the #join method
    # and (2) the heads from other table that (a) are known to be tested for
    # equality with a head in self table and (b) have the same name. Assume that
    # the expression will be evaluated in the context of a binding in which the
    # local variables are all the headers in the self table with '_a' appended
    # and all the headers in the other table with '_b' appended.
    def build_join_expression(exps, other, type)
      return ['true', []] if type == :cross
      a_heads = headers
      b_heads = other.headers
      common_heads = a_heads & b_heads
      b_common_heads = []
      if exps.empty?
        if common_heads.empty?
          raise ArgumentError,
                'A non-cross join with no common column names requires join expressions'
        else
          # A Natural join on all common heads
          common_heads.each do |h|
            ensure_common_types!(self_h: h, other_h: h, other: other)
          end
          nat_exp = common_heads.map { |h| "(#{h}_a == #{h}_b)" }.join(' && ')
          [nat_exp, common_heads]
        end
      else
        # We have expressions to evaluate
        and_conds = []
        partial_result = nil
        last_sym = nil
        exps.each do |exp|
          case exp
          when Symbol
            case exp.to_s.clean
            when /\A(.*)_a\z/
              a_head = $1.to_sym
              unless a_heads.include?(a_head)
                raise ArgumentError, "no column '#{a_head}' in table"
              end
              if partial_result
                # Second of a pair
                ensure_common_types!(self_h: a_head, other_h: last_sym, other: other)
                partial_result << "#{a_head}_a)"
                and_conds << partial_result
                partial_result = nil
              else
                # First of a pair of _a or _b
                partial_result = "(#{a_head}_a == "
              end
              last_sym = a_head
            when /\A(.*)_b\z/
              b_head = $1.to_sym
              unless b_heads.include?(b_head)
                raise ArgumentError, "no column '#{b_head}' in second table"
              end
              if partial_result
                # Second of a pair
                ensure_common_types!(self_h: last_sym, other_h: b_head, other: other)
                partial_result << "#{b_head}_b)"
                and_conds << partial_result
                partial_result = nil
              else
                # First of a pair of _a or _b
                partial_result = "(#{b_head}_b == "
              end
              b_common_heads << b_head
              last_sym = b_head
            else
              # No modifier, so must be one of the common columns
              unless partial_result.nil?
                # We were expecting the second of a modified pair, but got an
                # unmodified symbol instead.
                msg =
                  "must follow '#{last_sym}' by qualified exp from the other table"
                raise ArgumentError, msg
              end
              # We have an unqualified symbol that must appear in both tables
              unless common_heads.include?(exp)
                raise ArgumentError, "unqualified column '#{exp}' must occur in both tables"
              end
              ensure_common_types!(self_h: exp, other_h: exp, other: other)
              and_conds << "(#{exp}_a == #{exp}_b)"
              b_common_heads << exp
            end
          when String
            # We have a string expression in which all column references must be
            # qualified.
            and_conds << "(#{exp})"
          else
            raise ArgumentError, "invalid join expression '#{exp}' of class #{exp.class}"
          end
        end
        [and_conds.join(' && '), b_common_heads]
      end
    end

    # Raise an exception unless self_h in this table and other_h in other table
    # have the same types.
    def ensure_common_types!(self_h:, other_h:, other:)
      unless column(self_h).type == other.column(other_h).type
        raise ArgumentError,
              "type of column '#{self_h}' does not match type of column '#{other_h}"
      end
      self
    end

    public

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
          raise "Cannot group by parameter '#{xp}'"
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
        result << row
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
                                    items: items).send(agg_func)
      end
      new_row
    end

    ############################################################################
    # Table output methods.
    ############################################################################

    public

    def add_footer(label: 'Total', aggregate: :sum, heads: [])
      foot = {}
      heads.each do |h|
        raise "No #{h} column in table to #{aggregate}" unless headers.include?(h)
        foot[h] = column(h).send(aggregate)
      end
      @footers[label.as_sym] = foot
      self
    end

    def add_sum_footer(cols, label = 'Total')
      add_footer(heads: cols)
    end

    def add_avg_footer(cols, label = 'Average')
      add_footer(label: label, aggregate: :avg, heads: cols)
    end

    def add_min_footer(cols, label = 'Minimum')
      add_footer(label: label, aggregate: :min, heads: cols)
    end

    def add_max_footer(cols, label = 'Maximum')
      add_footer(label: label, aggregate: :max, heads: cols)
    end

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
          out_row << row[hdr].format_by(formats[hdr])
        end
        result << out_row
      end
      footers.each_pair do |label, footer|
        foot_row = []
        columns.each do |col|
          hdr = col.header
          foot_row << footer[hdr].format_by(formats[hdr])
        end
        foot_row[0] = label.entitle
        result << foot_row
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

    # Construct table from an array of hashes or an array of any object that can
    # respond to #to_hash.
    def from_array_of_hashes(rows)
      rows.each do |row|
        add_row(row.to_hash)
      end
      self
    end

    # Construct a new table from an array of arrays. If the second element of
    # the array is a nil, a string that looks like an hrule, or an array whose
    # first element is a string that looks like an hrule, interpret the first
    # element of the array as a row of headers. Otherwise, synthesize headers of
    # the form "col1", "col2", ... and so forth. The remaining elements are
    # taken as the body of the table, except that if an element of the outer
    # array is a nil or a string that looks like an hrule, mark the preceding
    # row as a boundary.
    def from_array_of_arrays(rows)
      hrule_re = /\A\s*\|[-+]+/
      headers = []
      if rows[1].nil? || rows[1] =~ hrule_re || rows[1].first =~ hrule_re
        # Take the first row as headers
        # Use first row 0 as headers
        headers = rows[0].map(&:as_sym)
        first_data_row = 2
      else
        # Synthesize headers
        headers = (1..rows[0].size).to_a.map { |k| "col#{k}".as_sym }
        first_data_row = 0
      end
      rows[first_data_row..-1].each do |row|
        if row.nil? || row[0] =~ hrule_re
          mark_boundary
          next
        end
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
          line = line.sub(/\A\s*\|/, '').sub(/\|\s*\z/, '')
          rows << line.split('|').map(&:clean)
          table_found = true
          next
        end
        break unless line =~ table_re
        if !header_found && line =~ hrule_re
          rows << nil
          header_found = true
          next
        elsif header_found && line =~ hrule_re
          # Mark the boundary with a nil
          rows << nil
        elsif line !~ table_re
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
