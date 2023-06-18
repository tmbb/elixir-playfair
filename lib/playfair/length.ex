defmodule Playfair.Length do
  defstruct terms: %{}

  defmacro sigil_L({:<<>>, _meta, [text]} = _content, _modifiers) do
    to_ast(text)
  end

  def new(amount, unit) do
    %__MODULE__{terms: %{unit => amount}}
  end

  def empty() do
    %__MODULE__{terms: %{}}
  end

  def drop_zeros(terms) do
    terms
    |> Enum.reject(fn {_unit, amount} -> amount == 0 or amount == 0.0 end)
    |> Enum.into(%{})
  end

  def add(%__MODULE__{} = d1, %__MODULE__{} = d2) do
    terms = Map.merge(d1.terms, d2.terms, fn _k, v1, v2 -> v1 + v2 end) |> drop_zeros()
    %__MODULE__{terms: terms}
  end

  def sub(%__MODULE__{} = d1, %__MODULE__{} = d2) do
    negative_d2_terms = d2.terms |> Enum.map(fn {k, v} -> {k, -v} end) |> Enum.into(%{})
    terms = Map.merge(d1.terms, negative_d2_terms, fn _k, v1, v2 -> v1 + v2 end) |> drop_zeros()
    %__MODULE__{terms: terms}
  end

  def mul(%__MODULE__{} = d, m) when is_integer(m) or is_float(m) do
    terms = Enum.map(d, fn {k, v} -> {k, m * v} end) |> Enum.into(%{})
    %__MODULE__{terms: terms}
  end

  def to_ast(text) do
    text |> String.split() |> parse_helper()
  end

  defp parse_helper([unparsed_term, "+" | rest]) do
    term = parse_term(unparsed_term)
    combination_of_terms = parse_helper(rest)

    quote do
      unquote(__MODULE__).add(unquote(term), unquote(combination_of_terms))
    end
  end

  defp parse_helper([unparsed_term, "-" | rest]) do
    term = parse_term(unparsed_term)
    combination_of_terms = parse_helper(rest)

    quote do
      unquote(__MODULE__).sub(unquote(term), unquote(combination_of_terms))
    end
  end

  defp parse_helper([unparsed_term]) do
    parse_term(unparsed_term)
  end

  defp parse_helper([]) do
    quote do
      unquote(__MODULE__).empty()
    end
  end

  def parse_term(text) do
    case Regex.named_captures(~r/(?<amount>-?\d+(\.\d+)?)(?<unit>[^0-9.]+)/, text) do
      %{"amount" => string_amount, "unit" => unit} ->
        amount =
          case Integer.parse(string_amount) do
            {amount, ""} -> amount
            _other ->
              {amount, ""} = Float.parse(string_amount)
              amount
          end

        quote do
          unquote(__MODULE__).new(unquote(amount), unquote(unit))
        end

      nil ->
        case Regex.named_captures(~r/(?<variable>[a-z][a-zA-Z0-9_]*(?|!)?)/, text) do
          %{"variable" => variable} ->
            Macro.var(String.to_atom(variable), nil)

          _other ->
            raise "Error parsing term: #{text}"
        end
    end
  end

  defp inspect_term({:+, text}), do: [" + ", text]
  defp inspect_term({:-, text}), do: [" - ", text]

  defp process_term(unit, amount) do
    if amount < 0 do
      {:-, "#{abs(amount)}#{unit}"}
    else
      {:+, "#{abs(amount)}#{unit}"}
    end
  end

  def length_to_iolist(length) do
    terms =
      length.terms
      |> Enum.sort()
      |> Enum.map(fn {unit, amount} -> process_term(unit, amount) end)

    iolist =
      case terms do
        [{:+, inspected_term} | rest] ->
          [inspected_term | Enum.map(rest, &inspect_term/1)]

        [{:-, inspected_term} | rest] ->
          ["-", inspected_term | Enum.map(rest, &inspect_term/1)]
      end

    iolist
  end

  def length_to_string(length) do
    iolist = length_to_iolist(length)
    IO.iodata_to_binary(iolist)
  end

  def to_typst(%__MODULE__{terms: terms} = _length) when terms == %{},
    do: {:raw, "0pt"}

  def to_typst(%__MODULE__{} = length),
    do: {:raw, length_to_string(length)}
end

defimpl Inspect, for: Playfair.Length do
  alias Playfair.Length

  def inspect(length, _opts \\ []) do
    IO.iodata_to_binary(["~L[", Length.length_to_iolist(length), "]"])
  end
end
