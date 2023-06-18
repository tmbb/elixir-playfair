defmodule Playfair.Formatter do
  def rounded_float(float, nr_of_decimal_places, format \\ :normal) do
    (float * 1.0)
    |> Decimal.from_float()
    |> Decimal.round(nr_of_decimal_places, :half_even)
    |> Decimal.to_string(format)
  end
end
