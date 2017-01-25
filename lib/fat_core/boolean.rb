class TrueClass
  def format_by(fmt = 'T')
    case fmt
    when /^[tf]/i
      'T'
    when /^[yn]/i
      'Y'
    else
      'T'
    end
  end
end

class FalseClass
  def format_by(fmt = 'T')
    case fmt
    when /^[tf]/i
      'F'
    when /^[yn]/i
      'N'
    else
      'F'
    end
  end
end
