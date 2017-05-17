module FatCore
  module NilClass
    def entitle
      ''
    end

    def tex_quote
      ''
    end

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
