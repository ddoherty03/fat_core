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

NilClass.include FatCore::NilClass
