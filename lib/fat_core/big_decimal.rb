require 'bigdecimal'

module FatCore
  module BigDecimal
    # Provide a human-readable display for BigDecimal. e.g., while debugging.
    def inspect
      to_f.to_s
    end
  end
end

class BigDecimal
  prepend(FatCore::BigDecimal)
  # @!parse include FatCore::BigDecimal
end
