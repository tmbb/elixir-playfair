defmodule Playfair.Typst.Serializer do
  alias Playfair.Typst
  alias Playfair.Typst

  @indent_advancement 2

  defp spaces(indent), do: String.duplicate(" ", indent)

  def serialize(ast) do
    serialize(ast, 0) |> IO.iodata_to_binary()
  end

  def serialize(i, _indent) when is_integer(i), do: to_string(i)
  def serialize(f, _indent) when is_float(f), do: to_string(f)
  def serialize(bin, _indent) when is_binary(bin), do: inspect(bin)
  def serialize(nil, _indent), do: "none"
  def serialize(atom, _indent) when is_atom(atom), do: to_string(atom)

  def serialize({:raw, text}, _indent), do: [text]

  def serialize({:let, pattern, value}, indent) do
    [
      "let ",
      serialize(pattern, indent + @indent_advancement),
      " = ",
      serialize(value, indent + @indent_advancement),
      "\n"
    ]
  end

  def serialize({:variable, binary}, _indent), do: [binary]

  def serialize({:method_call, object, method, args}, indent) do
    [
      serialize(object, indent),
      ".",
      serialize({:function_call, Typst.variable(method), args}, indent)
    ]
  end

  def serialize({:dictionary, items}, indent) do
    dict_spaces = spaces(indent)
    items_spaces = spaces(indent + @indent_advancement)

    serialized_items =
      for {key, value} <- items do
        [items_spaces, key, ": ", serialize(value, indent + @indent_advancement)]
      end

    comma_separated_args = Enum.intersperse(serialized_items, ",\n")

    [
      "(\n",
      comma_separated_args,
      "\n",
      dict_spaces,
      ")"
    ]
  end

  def serialize({:array, items}, indent) do
    array_spaces = spaces(indent)
    items_spaces = spaces(indent + @indent_advancement)

    serialized_items =
      Enum.map(items, fn item ->
        [items_spaces, serialize(item, indent + @indent_advancement)]
      end)

    # Trailing comma to avoid confusion between (x) and (x,)
    comma_separated_args = Enum.map(serialized_items, fn item -> [item, ",\n"] end)

    [
      "(\n",
      comma_separated_args,
      array_spaces,
      ")"
    ]
  end

  def serialize({:function_call, function, args}, indent) do
    call_spaces = spaces(indent)
    arg_spaces = spaces(indent + @indent_advancement)

    call = [serialize(function, indent), "("]

    serialized_args =
      for arg <- args do
        case arg do
          {:kw_arg, name, value} ->
            [arg_spaces, name, ": ", serialize(value, indent + @indent_advancement)]

          other ->
            [arg_spaces, serialize(other, indent + @indent_advancement)]
        end
      end

    comma_separated_args = Enum.intersperse(serialized_args, ",\n")

    close_parenthesis = [call_spaces, ")"]

    [
      call,
      "\n",
      comma_separated_args,
      "\n",
      close_parenthesis
    ]
  end
end
