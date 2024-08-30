# frozen_string_literal: true

module FatCore
  # Useful extensions to the core Array class.
  module Array
    # Return the index of the last element of this Array.  This is just a
    # convenience for an oft-needed Array attribute.
    def last_i
      size - 1
    end

    # Return a new Array that is the intersection of this Array with all
    # +others+, but without removing duplicates as the Array#& method
    # does. All items of this Array are included in the result but only if
    # they also appear in all of the other Arrays.
    def intersect_with_dups(*others)
      result = []
      each do |itm|
        result << itm if others.all? { |oth| oth.include?(itm) }
      end
      result
    end

    # Return an Array that is the difference between this Array and +other+, but
    # without removing duplicates as the Array#- method does. All items of this
    # Array are included in the result unless they also appear in the +other+
    # Array.
    def diff_with_dups(*others)
      result = []
      each do |itm|
        result << itm if others.none? { |oth| oth.include?(itm) }
      end
      result
    end

    # Convert this array into a single string by (1) applying #to_s to each
    # element and (2) joining the elements with the string given by the sep:
    # paramater. By default the sep parameter is ', '. You may use a different
    # separation string in the case when there are only two items in the list
    # by supplying a two_sep parameter.  You may also supply a difference
    # separation string to separate the second-last and last items in the
    # array by supplying a last_sep: parameter.  By default, the sep parameter
    # is the string ', ', the two_sep is ' and ', and the last_sep is ', and
    # ', all of which makes for a well-punctuated English clause.  If sep is
    # given, the other two parameters are set to its value by default.  If
    # last_sep is given, two_sep takes its value by default.  If the input
    # array is empty, #comma_join returns an empty string.
    def comma_join(sep: nil, last_sep: nil, two_sep: nil)
      orig_sep = sep
      orig_last_sep = last_sep
      sep ||= ', '
      last_sep ||= orig_sep || ', and '
      two_sep ||=  orig_sep || orig_last_sep || ' and '
      result = +''
      case size
      when 0
        result
      when 1
        result = self[0].to_s
      when 2
        result = self[0].to_s + two_sep + self[1]
      else
        second_last = size - 2
        last = size - 1
        each_with_index do |itm, k|
          result <<
            if k == second_last
              "#{itm}#{last_sep}"
            elsif k == last
              itm.to_s
            else
              "#{itm}#{sep}"
            end
        end
      end
      result
    end
  end
end

class Array
  include FatCore::Array
  # @!parse include FatCore::Array
end
