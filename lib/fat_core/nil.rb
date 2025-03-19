# frozen_string_literal: true

module FatCore
  module NilClass
    # Allow nils to respond to #entitle like String and Symbol
    #
    # @return [String] empty string
    def entitle
      ''
    end

    # Allow nils to respond to #tex_quote for use in TeX documents
    #
    # @return [String] empty string
    def tex_quote
      ''
    end

    # Allow nils to respond to #commas like String and Numeric
    #
    # @return [String] empty string
    def commas(_places = nil)
      ''
    end
  end
end

class NilClass
  include FatCore::NilClass
  # @!parse include FatCore::NilClass
  # @!parse extend FatCore::NilClass::ClassMethods
end
