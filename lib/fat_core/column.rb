module FatCore
  # Column objects are just a thin wrapper around an Array to allow columns to
  # be summed and have other operations performed on them, but compacting out
  # nils before proceeding. My original attempt to do this by monkey-patching
  # Array turned out badly.  This works much nicer.
  class Column
    attr_reader :header, :type, :items

    TYPES = %w(NilClass TrueClass FalseClass Date DateTime Numeric String)

    def initialize(header:, items: [])
      @header = header.as_sym
      @type = 'NilClass'
      raise "Unknown column type '#{type}" unless TYPES.include?(@type.to_s)
      @items = []
      items.each { |i| self << i }
    end

    def <<(itm)
      items << convert_to_type(itm)
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

    # Return a new Column appending the items of other to our items, checking
    # for type compatibility.
    def +(other)
      raise 'Cannot combine columns with different types' unless type == other.type
      Column.new(header: header, items: items + other.items)
    end

    def first
      items.compact.first
    end

    def last
      items.compact.last
    end

    # Return a string that of the first and last values.
    def rng_s
      "#{first}..#{last}"
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
      sum / items.compact.size.to_d
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
    def convert_to_type(val)
      case type
      when 'NilClass'
        if val != false && val.blank?
          # Leave the type of the column open. Unfortunately, false counts as
          # blank and we don't want it to. It should be classified as a boolean.
          new_val = nil
        else
          # Only non-blank values are allowed to set the type of the column
          bool_val = convert_to_boolean(val)
          new_val =
            if bool_val.nil?
              convert_to_date_time(val) ||
                convert_to_numeric(val) ||
                convert_to_string(val)
            else
              bool_val
            end
          @type =
            if new_val == true || new_val == false
              'Boolean'
            elsif new_val.is_a?(Numeric)
              'Numeric'
            else
              new_val.class.name
            end
        end
        new_val
      when 'Boolean', 'TrueClass', 'FalseClass'
        if val.nil?
          nil
        else
          new_val = convert_to_boolean(val)
          if new_val.nil?
            raise "Attempt to add '#{val}' to a column already typed as #{type}"
          end
          new_val
        end
      when 'DateTime', 'Date'
        if val.nil?
          nil
        else
          new_val = convert_to_date_time(val)
          if new_val.nil?
            raise "Attempt to add '#{val}' to a column already typed as #{type}"
          end
          new_val
        end
      when 'Numeric'
        if val.nil?
          nil
        else
          new_val = convert_to_numeric(val)
          if new_val.nil?
            raise "Attempt to add '#{val}' to a column already typed as #{type}"
          end
          new_val
        end
      when 'String'
        if val.nil?
          nil
        else
          new_val = convert_to_string(val)
          if new_val.nil?
            raise "Attempt to add '#{val}' to a column already typed as #{type}"
          end
          new_val
        end
      else
        raise "Mysteriously, column has unknown type '#{type}'"
      end
    end

    # Convert the val to a boolean if it looks like one, otherwise return nil.
    # Any boolean or a string of t, f, true, false, y, n, yes, or no, regardless
    # of case is assumed to be a boolean.
    def convert_to_boolean(val)
      return val if val.is_a?(TrueClass) || val.is_a?(FalseClass)
      val = val.to_s.clean
      return nil if val.blank?
      if val =~ /\A(false|f|n|no)\z/i
        false
      elsif val =~ /\A(true|t|y|yes)\z/i
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
      return val.to_datetime if val.is_a?(Date) && type == 'DateTime'
      return val if val.is_a?(Date)
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
