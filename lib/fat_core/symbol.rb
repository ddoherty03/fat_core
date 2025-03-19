# frozen_string_literal: true

require 'fat_core/string'

module FatCore
  module Symbol
    # Convert to a title-ized string, that is, convert all '_' to a space, then
    # call String#entitle on the result.
    #
    # @example
    #   :hello_world.entitle #=> "Hello World"
    #   :joy_to_the_world #=> 'Joy to the World'
    #
    # @return [String]
    def entitle
      to_s.tr('_', ' ').split.join(' ').entitle
    end

    # Return self. This (together with String#as_sym) allows `#as_sym` to be
    # applied to a string or Symbol and get back a Symbol with out testing for
    # type.
    #
    # @return [Symbol] just self
    def as_sym
      self
    end

    # Convert this symbol to a string in such a manner that for simple cases,
    # it is the inverse of String#as_sym and vice-versa.
    def as_str
      to_s
        .downcase
        .tr('_', '-')
        .gsub(/[^-_A-Za-z0-9]/, '')
    end

    # Prepare this symbol for use in a TeX document by converting to String then
    # quoting it.
    #
    # @example
    #   :hammer_smith.tex_quote  #=> "hammer\\_smith"
    #
    # @return [String]
    def tex_quote
      to_s.tex_quote
    end
  end
end

class Symbol
  include FatCore::Symbol
  # @!parse include FatCore::Symbol
  # @!parse extend FatCore::Symbol::ClassMethods
end
