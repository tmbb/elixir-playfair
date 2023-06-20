defmodule Playfair.Plot2D.XYPlot.BoxPlot do
  import Playfair.Length, only: [sigil_L: 2]
  alias Playfair.Plot2D.XYPlot
  alias Playfair.Plot2D.XYAxis

  @typst_plotter :boxplot

  seed_number_of_digits = 12

  seed_from_exponent = fn exponent ->
    # Get the digits from the decimal expansion of a power of pi
    # We need `seed_nr_of_digits`, and those digits can't be the most significant,
    # as that "wastes" entropy. So we'll get three more decimal places than we need
    # and then pick the `seed_nr_of_digits` less significant ones
    power_of_pi = :math.pow(:math.pi, exponent) * (10 ** (seed_number_of_digits + 3))
    # Get the least significant `seed_nr_of_digits` for the seed
    rem(round(power_of_pi), 10 ** seed_number_of_digits)
  end

  # Deterministic seeds from powers of pi
  @seed1 seed_from_exponent.(1/3)
  @seed2 seed_from_exponent.(1/5)
  @seed3 seed_from_exponent.(1/7)


  def plot(plot, x_axis_name, y_axis_name, data, opts \\ []) do
    n = length(data)

    x_tick_locations = for i <- 1..n, do: ((i - 0.5)/n)

    pairs =
      for {{_label, ys}, x} <- Enum.zip(data, x_tick_locations) do
        jitter = Keyword.get(opts, :jitter, true)
        jitter_width = Keyword.get(opts, :jitter_width, ~L[7pt])
        jitter_random_seed = Keyword.get(opts, :jitter_random_seed, @seed1)

        box_data = box_data(x, ys, jitter, jitter_width, jitter_random_seed)

        # All data-related points must be between 0 and 1.
        # This includes the whiskers.
        # Whiskers can be higher or lower than any data point,
        # which means they need to be included when we want
        # to evaluate the maximum and minimum for scaling purposes.
        all_ys = [box_data.whisker_low, box_data.whisker_high | ys]

        {Enum.min_max(all_ys), box_data}
      end


    {min_maxes, box_data} = Enum.unzip(pairs)
    {y_mins, y_maxs} = Enum.unzip(min_maxes)

    y_min = Enum.min(y_mins)
    y_max = Enum.max(y_maxs)

    # TODO: Deal with escaping somehow
    x_tick_labels =
      for {label, _ys} <- data do
        label
      end

    plot =
      XYPlot.update_axis(plot, y_axis_name, fn axis ->
        axis
        |> XYAxis.maybe_update_min_value(y_min)
        |> XYAxis.maybe_update_max_value(y_max)
      end)

    plot =
      XYPlot.update_axis(plot, x_axis_name, fn axis ->
        axis
        |> XYAxis.put_min_value(0.0)
        |> XYAxis.put_max_value(1.0)
        |> XYAxis.put_major_tick_labels(x_tick_labels)
        |> XYAxis.put_major_tick_locations(x_tick_locations)
      end)

    data_spec = %{
      elixir_plotter: __MODULE__,
      x_axis_name: x_axis_name,
      y_axis_name: y_axis_name,
      x_min: 0.0,
      x_max: 1.0,
      y_min: y_min,
      y_max: y_max,
      plotter: @typst_plotter,
      data: box_data
    }

    %{plot | plot_blueprints: [data_spec | plot.plot_blueprints]}
  end

  defp box_data(x, list, jitter, jitter_width, jitter_random_seed) do
    sorted_list = Enum.sort(list)
    n = length(sorted_list)

    i_q1 = round(n * 0.25)
    i_q2 = round(n * 0.5)
    i_q3 = round(n * 0.75)

    q1 = Enum.at(sorted_list, i_q1)
    median = Enum.at(sorted_list, i_q2)
    q3 = Enum.at(sorted_list, i_q3)

    iqr = q3 - q1

    whisker_low = q1 - iqr
    whisker_high = q3 + iqr

    outliers_high = Enum.filter(sorted_list, fn y -> y > whisker_high end)
    outliers_low = Enum.filter(sorted_list, fn y -> y < whisker_low end)

    :rand.seed(:exsplus, {jitter_random_seed, @seed2, @seed3})

    jitter_low =
      case jitter do
        true ->
          Enum.map(outliers_low, fn _ -> :rand.uniform() - 0.5 end)

        false ->
          nil
      end

    jitter_high =
      case jitter do
        true ->
          Enum.map(outliers_high, fn _ -> :rand.uniform() - 0.5 end)

        false ->
          nil
      end

    %{
      x: x,
      jitter_width: jitter_width,
      outliers_low: outliers_low,
      jitter_low: jitter_low,
      whisker_low: whisker_low,
      q1: q1,
      median: median,
      q3: q3,
      whisker_high: whisker_high,
      outliers_high: outliers_high,
      jitter_high: jitter_high
    }
  end

  def apply_scale(x_axis, y_axis, plot_blueprint) do
    %{data: data} = plot_blueprint

    scaled_data =
      for box_data <- data do
        %{
          x: x,
          jitter_width: jitter_width,
          outliers_low: outliers_low,
          jitter_low: jitter_low,
          whisker_low: whisker_low,
          q1: q1,
          median: median,
          q3: q3,
          whisker_high: whisker_high,
          outliers_high: outliers_high,
          jitter_high: jitter_high
        } = box_data

        %{box_data |
          # This is the only parameter that will be scaled
          # according to the x_axis
          x: XYAxis.apply_scale(x_axis, x),
          jitter_width: jitter_width,
          outliers_low: XYAxis.apply_scale_to_many(y_axis, outliers_low),
          # Don't scale horizontal jitter; it uses absolute units
          jitter_low: jitter_low,
          whisker_low: XYAxis.apply_scale(y_axis, whisker_low),
          q1: XYAxis.apply_scale(y_axis, q1),
          median: XYAxis.apply_scale(y_axis, median),
          q3: XYAxis.apply_scale(y_axis, q3),
          whisker_high: XYAxis.apply_scale(y_axis, whisker_high),
          outliers_high: XYAxis.apply_scale_to_many(y_axis, outliers_high),
          # Don't scale horizontal jitter; it uses absolute units
          jitter_high: jitter_high
        }
    end

    %{plot_blueprint | data: scaled_data}
  end
end
