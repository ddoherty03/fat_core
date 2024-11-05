# frozen_string_literal: true

require 'fat_core/string'

module FatCore
  module Symbol
    # Convert to a title-ized string, that is, convert all '_' to a space, then
    # call String#entitle on the result.
    #
    # @example
    #   :hello_world.entitle #=> "Hello World"
    #   :hello_world.as_string #=> "Hello World"
    #   :joy_to_the_world #=> 'Joy to the World'
    #
    # @return [String]
    def as_string
      to_s.tr('_', ' ').split.join(' ').entitle
    end
    alias_method :entitle, :as_string

    # Return self. This (together with String#as_sym) allows `#as_sym` to be
    # applied to a string or Symbol and get back a Symbol with out testing for
    # type.
    #
    # @return [Symbol] just self
    def as_sym
      self
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
