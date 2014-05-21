require 'erubis'
require 'erubis/enhancer'
require 'erubis/helper'

class LaTeXEruby < Erubis::Eruby
  include Erubis::EscapeEnhancer

  def escaped_expr(code)
    code.nil? ? '' : "(#{code}).tex_quote"
  end
end
