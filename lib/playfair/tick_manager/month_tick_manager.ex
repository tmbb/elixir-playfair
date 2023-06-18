defmodule Playfair.TickManagers.MonthsTickManager do
  alias Playfair.Formatter

  def init(opts \\ []) do
    _max_nr_of_ticks = Keyword.get(opts, :max_nr_of_ticks, 7)

    {__MODULE__, opts}
  end

  def add_major_ticks(axis, opts) do
    max_nr_of_ticks = Keyword.fetch!(opts, :max_number_of_ticks)
    delta = axis.max_value - axis.min_value

    step = round(delta / (12 * max_nr_of_ticks))

    # Truncate towards zero
    iteration_min = trunc(axis.min_value / step)
    # Truncate towards zero
    iteration_max = trunc(axis.max_value / step)

    tick_locations = for i <- iteration_min..iteration_max, do: step * i
    nr_of_decimal_places = 0

    tick_labels =
      for value <- tick_locations do
        Formatter.rounded_float(value, nr_of_decimal_places)
      end

    %{axis | major_tick_locations: tick_locations, major_tick_labels: tick_labels}
  end
end
