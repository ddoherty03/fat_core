module FatCore
  # Output the table as plain text. This is almost identical to OrgFormatter
  # except that dates do not get formatted as inactive timestamps and the
  # connector at the beginning of hlines is a '+' rather than a '|' as for org
  # tables.
  class LaTeXFormatter < Formatter

    def decorable?
      true
    end

    # Add LaTeX control sequences. Ignore background color, underline, and
    # blink. Alignment needs to be done by LaTeX, so we have to take it into
    # account unless it's the same as the body alignment, since that is the
    # default.
    def decorate_string(str, istruct)
      str = quote_for_decorate(str)
      result = ''
      result += '\\bfseries{}' if istruct.bold
      result += '\\itshape{}' if istruct.italic
      result += "\\color{#{istruct.color}}" if istruct.color && istruct.color != 'none'
      result = "#{result}#{str}"
      unless istruct.alignment == format_at[:body][istruct._h].alignment
        ac = alignment_code(istruct.alignment)
        result = "\\multicolumn{1}{#{ac}}{#{result}}"
      end
      result
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
