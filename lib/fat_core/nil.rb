class NilClass
  def entitle
    nil
  end

  def tex_quote
    ''
  end

  # It is important at certain places (e.g., Hash#values_to_db_types) that a
  # nil respond to to_amount and give a zero, so an empty :dr or :cr simply
  # gets added to the other in forming an entry's amount.  That's why this is
  # here, just so you know.
  def to_amount
    z = BigDecimal('0.0')
    {quantity: nil, commodity: nil, price: nil, amount: z}
  end
end
