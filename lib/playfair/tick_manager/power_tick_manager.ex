defmodule Playfair.TickManagers.PowerMajorTickManager do
  alias Playfair.Formatter

  def nr_of_multiples_of_n_between(n, a, b) do
    round(:math.floor(b/n) + :math.ceil(a/n) + 1)
  end

  def init(opts \\ [base: 10, nr_of_decimal_places: nil]), do: {__MODULE__, opts}

  def add_major_ticks(axis, opts) do
    base = Keyword.fetch!(opts, :base)
    supplied_nr_of_decimal_places = Keyword.get(opts, :nr_of_decimal_places)

    delta = axis.max_value - axis.min_value

    exponent_float = :math.log(delta) / :math.log(base)
    exponent = round(exponent_float - 1)
    # This works because of the way Decimal handles negative numbers
    # of decimal places
    nr_of_decimal_places =
      if supplied_nr_of_decimal_places,
        do: supplied_nr_of_decimal_places,
        else: -exponent

    step = base ** exponent

    # Truncate towards zero
    iteration_min = trunc(axis.min_value / step)
    # Truncate towards zero
    iteration_max = trunc(axis.max_value / step)

    tick_locations = for i <- iteration_min..iteration_max, do: step * i

    tick_labels =
      for value <- tick_locations do
        Formatter.rounded_float(value, nr_of_decimal_places)
      end

    %{axis | major_tick_locations: tick_locations, major_tick_labels: tick_labels}
  end
end
