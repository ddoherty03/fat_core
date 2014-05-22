class Array
  # Duplicate each element of an Array into a new Array
  def dup2
    newa = []
    self.each { |e|
      newa << e.dup
    }
    return newa
  end

  def last_i
    self.size - 1
  end
end
