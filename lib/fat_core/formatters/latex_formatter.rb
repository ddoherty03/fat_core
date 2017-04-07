module FatCore
  # Output the table as plain text. This is almost identical to OrgFormatter
  # except that dates do not get formatted as inactive timestamps and the
  # connector at the beginning of hlines is a '+' rather than a '|' as for org
  # tables.
  class LaTeXFormatter < Formatter

    def decorable?
      true
    end

    # Add LaTeX control sequences, ANSI terminal escape codes, or other
    # decorations to string to decorate it with the given attributes. None of
    # the decorations may affect the displayed width of the string. Return the
    # decorated string.
    def decorate_string(str, color: 'none', bgcolor: 'none',
                        bold: false, italic: false,
                        underline: false, blink: false)
      str = quote_for_decorate(str)
      result = ''
      result += '\\bfseries' if bold
      result += '\\itshape' if italic
      result += "\\color{#{color}}" if color && color != 'none'
      "{#{result}{#{str}}}"
    end

    def quote_for_decorate(str)
      result = str.gsub(/'([^']*)'/, "`\\1'")
      result = result.gsub(/"([^"]*)"/, "``\\1''")
      result.tex_quote
    end

    def self.preamble
      "\\usepackage{longtable}\n
      \\usepackage[pdftex,x11names]{xcolor}\n"
    end

    def pre_table
      result = '\\begin{longtable}{'
      table.headers.each do |h|
        result +=
          case format_at[:body][h].alignment
          when :center
            'c'
          when :right
            'r'
          else
            'l'
          end
      end
      result += "}\n"
      result
    end

    def post_table
      "\\end{longtable}\n"
    end

    def post_header(_widths)
      "\\endhead\n"
    end

    def pre_row
      ''
    end

    def pre_cell(_h)
      ''
    end

    # We do quoting before applying decoration, so do not re-quote here.  We
    # will have LaTeX commands in v.
    def quote_cell(v)
      v
    end

    def post_cell
      ''
    end

    def inter_cell
      "&\n"
    end

    def post_row
      "\\\\\n"
    end

    # Hlines look to busy in a printed table
    def hline(widths)
      ''
    end

    def pre_group
      ''
    end

    def post_group
      ''
    end

    def pre_gfoot
      ''
    end

    def post_gfoot
      ''
    end

    def pre_foot
      ''
    end

    def post_foot
      ''
    end

    # Hlines look to busy in a printed table
    def post_footers(widths)
      '' #"\\hline\\hline\n"
    end
  end
end
