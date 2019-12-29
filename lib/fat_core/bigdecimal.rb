require 'bigdecimal'

module FatCore
  # Extensions to BigDecimal class
  module BigDecimal
    # Provide a human-readable display for BigDecimal. e.g., while debugging.
    # The inspect method in BigDecimal is unreadable, as it exposes the
    # underlying implementation, not the number's value. This corrects that.
    #
    # @return [String]
    def inspect
      to_f.to_s
    end
  end
end

# Override the core inspect method.
class BigDecimal
  prepend(FatCore::BigDecimal)
  # @!parse include FatCore::BigDecimal
end
