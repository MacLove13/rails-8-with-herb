# frozen_string_literal: true

# Configure Herb as the ERB rendering engine for ActionView.
# Herb provides an HTML-aware ERB engine with validation, linting,
# and enhanced developer tooling. https://herb-tools.dev

# ActionViewHerb wraps Herb::Engine to be compatible with ActionView's SafeBuffer,
# using safe_append= for literal HTML text (so it is not HTML-escaped) and
# append= / safe_expr_append= for dynamic ERB expressions.
class ActionViewHerb < Herb::Engine
  def initialize(input, properties = {})
    properties = Hash[properties]
    properties[:bufvar]   ||= "@output_buffer"
    properties[:preamble] ||= ""
    properties[:postamble] ||= "#{properties[:bufvar]}"
    super
  end

private

  BLOCK_EXPR = /((\s|\))do|\{)(\s*\|[^|]*\|)?\s*\Z/

  # Override add_text to use OutputBuffer#safe_append= so literal HTML is
  # not HTML-escaped by ActionView's SafeBuffer.
  def add_text(text)
    return if text.empty?

    escaped = text.gsub(/['\\]/, '\\\\\&')
    @src << " #{@bufvar}.safe_append='#{escaped}';"
  end

  # Override add_expression to use OutputBuffer#safe_expr_append= (unescaped)
  # or OutputBuffer#append= (escaped) so that ERB output is handled correctly.
  def add_expression(indicator, code)
    if (indicator == "==") || @escape
      @src << " #{@bufvar}.safe_expr_append=(#{code});"
    else
      if BLOCK_EXPR.match?(code)
        @src << " #{@bufvar}.append= #{code};"
      else
        @src << " #{@bufvar}.append=(#{code});"
      end
    end
  end
end

ActionView::Template::Handlers::ERB.erb_implementation = ActionViewHerb
