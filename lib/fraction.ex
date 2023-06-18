defmodule Fraction do
  @doc """
  Sigil for fractions. Compiles to `Rational.new/2`.
  """
  defmacro sigil_f({:<<>>, _meta, [text]} = _content, _modifiers) do
    case Code.string_to_quoted!(text) do
      {:/, _meta, [numerator, denominator]} ->
        quote do
          Ratio.new(unquote(numerator), unquote(denominator))
        end

      _other ->
        raise ArgumentError, "Invalid fraction ~f'#{text}'."
    end
  end
end
