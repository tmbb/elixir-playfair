defmodule Playfair.Typst do
  alias Playfair.Typst.Color.RGB
  alias Playfair.Plot2D.XYAxis
  alias Playfair.Length
  alias Playfair.Typst.Text

  def raw(text), do: {:raw, text}

  def map_to_kw_args(map) do
    map
    |> Map.delete(:__struct__)
    |> Enum.into([])
    |> Enum.map(fn {k, v} -> kw_arg(k, v) end)
  end

  def proplist_to_kw_args(proplist) do
    Enum.map(proplist, fn {k, v} -> kw_arg(k, v) end)
  end

  def underscore_in_keys_to_hyphen(list) when is_list(list) do
    for {key, value} <- list do
      new_key =
        key
        |> to_string()
        |> String.replace("_", "-")

      {new_key, value}
    end
  end

  def underscore_in_keys_to_hyphen(%{} = map) do
    map
    |> Enum.into([])
    |> underscore_in_keys_to_hyphen()
    |> Enum.into(%{})
  end

  def text(content, opts \\ []) do
    Text.new(content, opts)
  end

  def operator(operator, left, right),
    do: {:operator, operator, left, right}

  def sequence(elements), do: {:sequence, elements}

  def kw_arg(name, value) when is_binary(name) or is_atom(name),
    do: {:kw_arg, to_string(name), to_typst(value)}

  def let(pattern, value), do: {:let, pattern, value}

  def function_call(function, args) when is_list(args),
    do: {:function_call, function, args}

  def method_call(object, method, args),
    do: {:method_call, object, to_string(method), args}

  def dictionary(items),
    do: {:dictionary, Enum.map(items, fn {k, v} -> {to_string(k), v} end)}

  def array(items), do: {:array, items}

  def variable(binary), do: {:variable, to_string(binary)}

  def angle(value, unit) when unit in [:deg, :rad], do: {:angle, value, unit}

  def to_typst(%Length{} = length) do
    Length.to_typst(length)
  end

  def to_typst(%RGB{} = rgb) do
    {:function_call, variable("rgb"), [rgb.r, rgb.g, rgb.b, rgb.a]}
  end

  def to_typst(%Text{} = text), do: Text.to_typst(text)

  def to_typst(map) when map == %{} do
    # Add a dummy key to empty maps so that they are not confused with arrays
    dictionary(__map__: variable(:none))
  end

  def to_typst(%XYAxis{} = axis), do: XYAxis.to_typst(axis)

  def to_typst(%{} = map) do
    map
    |> Enum.map(fn {k, v} -> {to_string(k), to_typst(v)} end)
    |> dictionary()
  end

  def to_typst(items) when is_list(items) do
    items
    |> Enum.map(&to_typst/1)
    |> array()
  end

  def to_typst(nil), do: variable(:none)


  def to_typst(i) when is_integer(i), do: i
  def to_typst(f) when is_float(f), do: f
  def to_typst(binary) when is_binary(binary), do: binary
  def to_typst(var) when is_atom(var), do: variable(var)

  def to_typst(other), do: other

  def example() do
    alias Playfair.Typst.Serializer

    ast =
      let(
        variable("size"),
        function_call("measure", [
          function_call("stack", [
            kw_arg("dir", variable("ttb")),
            array(for i <- 0..14, do: i/3),
            variable("box1"),
            dictionary(a: variable("a1"), b: variable("b2")),
            method_call(variable("my-dict"), "at", [
              variable("x-size"),
              kw_arg("default", variable("default-x-size"))
            ])
          ]),
          variable("styles")
        ])
      )

    Serializer.serialize(ast) |> IO.puts()
  end
end
