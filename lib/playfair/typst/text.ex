defmodule Playfair.Typst.Text do
  alias Playfair.Typst

  defstruct font: nil,
            fallback: nil,
            style: nil,
            weight: nil,
            stretch: nil,
            size: nil,
            fill: nil,
            tracking: nil,
            spacing: nil,
            baseline: nil,
            overhang: nil,
            top_edge: nil,
            bottom_edge: nil,
            lang: nil,
            region: nil,
            dir: nil,
            hyphenate: nil,
            kerning: nil,
            alternates: nil,
            stylistic_set: nil,
            ligatures: nil,
            discretionary_ligatures: nil,
            historical_ligatures: nil,
            number_type: nil,
            number_width: nil,
            slashed_zero: nil,
            fractions: nil,
            features: nil,
            escape: true,
            content: nil

  def new(binary, opts \\ []) do
    all_opts = Keyword.put(opts, :content, binary)
    struct(__MODULE__, all_opts)
  end

  def to_typst(text) do
    content =
      case text.escape do
        true -> text.content
        false -> Typst.raw("[#{text.content}]")
      end

    kw_args =
      text
      |> Map.drop([:__struct__, :content, :escape])
      |> Enum.reject(fn {_key, value} -> value == nil end)
      |> Typst.underscore_in_keys_to_hyphen()
      |> Typst.proplist_to_kw_args()

    Typst.function_call(
      Typst.variable("text"),
      kw_args ++ [content]
    )
  end
end
