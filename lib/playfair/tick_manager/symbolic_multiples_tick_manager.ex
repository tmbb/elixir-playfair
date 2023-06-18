defmodule Playfair.TickManagers.SymbolicMultiplesTickManager do
  def init(opts \\ []) do
    as_symbolic = Keyword.fetch!(opts, :as_symbolic)
    step = Keyword.fetch!(opts, :step)

    {__MODULE__, [as_symbolic: as_symbolic, step: step]}
  end

  def add_major_ticks(axis, opts) do
    step = Keyword.fetch!(opts, :step)
    as_symbolic = Keyword.fetch!(opts, :as_symbolic)

    # Truncate towards zero
    iteration_min = trunc(:math.floor(axis.min_value / step))
    # Truncate towards zero
    iteration_max = trunc(:math.ceil(axis.max_value / step))

    tick_locations = for i <- iteration_min..iteration_max, do: step * i

    tick_labels =
      for i <- iteration_min..iteration_max do
        as_symbolic.(i)
      end

    %{axis | major_tick_locations: tick_locations, major_tick_labels: tick_labels}
  end
end
