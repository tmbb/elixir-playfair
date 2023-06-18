defmodule Playfair.TickManagers.AutoTickManager do
  alias Playfair.Formatter

  @steps [1, 2, 2.5, 5, 10]

  def init(opts \\ []) do
    {__MODULE__, opts}
  end

  defp step_and_major_tick_locations(
        min_value,
        max_value,
        add_below_min?,
        add_above_max?,
        opts
      ) do

    desired_nr_of_ticks = Keyword.get(opts, :desired_nr_of_ticks, 7)

    desired_nr_of_inner_ticks =
      case {add_below_min?, add_above_max?} do
        {true, true} -> desired_nr_of_ticks - 2
        {true, false} -> desired_nr_of_ticks - 1
        {false, true} -> desired_nr_of_ticks - 1
        {false, false} -> desired_nr_of_ticks
      end

    range = max_value - min_value

    a1 = floor(:math.log10(range))
    a2 = a1 + 1
    a0 = a1 - 1

    candidates_0 = Enum.map(@steps, fn x -> x * :math.pow(10.0, a0) end)
    candidates_1 = Enum.map(@steps, fn x -> x * :math.pow(10.0, a1) end)
    candidates_2 = Enum.map(@steps, fn x -> x * :math.pow(10.0, a2) end)

    candidates = candidates_0 ++ candidates_1 ++ candidates_2

    nrs_of_multiples =
      Enum.map(
        candidates,
        fn step -> {step, nr_of_multiples_between(step, min_value, max_value)} end
      )

    {step, n} =
      Enum.min_by(nrs_of_multiples, fn {_step, n} ->
        abs(n - desired_nr_of_inner_ticks)
      end)

    start = ceil(min_value / step) * step
    locations = for i <- 0..(n - 1), do: start + (i * step)

    min_tick = Enum.min(locations)
    max_tick = Enum.max(locations)

    locations =
      if add_below_min? and min_tick > min_value,
        do: [min_tick - step | locations],
        else: locations

    locations =
      if add_above_max? and max_tick < max_value,
        do: locations ++ [max_tick + step],
        else: locations

    {step, locations}
  end

  def major_tick_locations(
        min_value,
        max_value,
        add_below_min?,
        add_above_max?,
        opts \\ []
      ) do

    {_step, locations} =
      step_and_major_tick_locations(
        min_value,
        max_value,
        add_below_min?,
        add_above_max?,
        opts
      )

    locations
  end

  def nr_of_multiples_between(n, a, b) do
    abs(floor(b / n) - ceil(a / n)) + 1
  end

  def add_major_ticks(%{min_value: min_value, max_value: max_value} = axis, _opts)
    when min_value == nil or max_value == nil do
      %{axis | major_tick_locations: [], major_tick_labels: []}
  end

  def add_major_ticks(axis, opts) do
    supplied_nr_of_decimal_places = Keyword.get(opts, :nr_of_decimal_places)

    # Only add the limits when the axis limits haven't been explicitly set
    add_below_min? = axis.min_value_set_by_user == false
    add_above_max? = axis.max_value_set_by_user == false

    {step, tick_locations} =
      step_and_major_tick_locations(
        axis.min_value,
        axis.max_value,
        add_below_min?,
        add_above_max?,
        opts
      )

    exponent = min(floor(:math.log10(step)), 0)

    # This works because of the way Decimal handles negative numbers
    # of decimal places
    nr_of_decimal_places =
      if supplied_nr_of_decimal_places,
        do: supplied_nr_of_decimal_places,
        else: -exponent


    tick_labels =
      for value <- tick_locations do
        Formatter.rounded_float(value, nr_of_decimal_places)
      end

    new_max_value = max(axis.max_value, Enum.max(tick_locations))
    new_min_value = min(axis.min_value, Enum.min(tick_locations))

    %{axis |
        max_value: new_max_value, min_value: new_min_value,
        major_tick_locations: tick_locations, major_tick_labels: tick_labels}
  end
end
