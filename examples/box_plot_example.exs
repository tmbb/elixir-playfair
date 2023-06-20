defmodule Playfair.Examples.BoxPlotExamples do
  alias Playfair.Plot2D.XYPlot
  import Playfair.Length, only: [sigil_L: 2]
  alias Playfair.Config

  # Generate random data for a normal distribution
  defp norm(mu, sigma) do
    Statistics.Distributions.Normal.rand(mu, sigma)
  end

  def data() do
    # Ensure deterministic data
    :rand.seed(:exsplus, {0, 42, 0})

    [
      {"Group A", Enum.map(1..50, fn _ -> norm(500.0, 170.00) end)},
      {"Group B", Enum.map(1..60, fn _ -> norm(400.0, 100.0) end)},
      {"Group C", Enum.map(1..30, fn _ -> norm(790.0, 60.0) end)},
      {"Group D", Enum.map(1..80, fn _ -> norm(500.0, 150.0) end)},
    ]
  end

  def run_barebones() do
    XYPlot.new()
    |> XYPlot.boxplot("x", "y", data())
    |> XYPlot.render_to_pdf_file!("examples/box-plot-example-barebones.pdf")
  end

  def run_with_labels() do
    XYPlot.new()
    |> XYPlot.boxplot("x", "y", data())
    # Add labels to the X and Y axes ――――――――――――――――――――――――――――――――――――――――――――――――――――
    |> XYPlot.put_axis_label("y", "Reaction time (ms)")
    |> XYPlot.put_axis_label("x", "Populations")
    # ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
    |> XYPlot.render_to_pdf_file!("examples/box-plot-example-with-labels.pdf")
  end

  def run_with_title() do
    XYPlot.new()
    |> XYPlot.boxplot("x", "y", data())
    # Add a title to the plot ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
    |> XYPlot.put_title("A. Reaction time according to group")
    # ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
    |> XYPlot.put_axis_label("y", "Reaction time (ms)")
    |> XYPlot.put_axis_label("x", "Populations")
    |> XYPlot.render_to_pdf_file!("examples/box-plot-example-with-title.pdf")
  end

  def run_with_styled_labels_and_title() do
    XYPlot.new()
    |> XYPlot.boxplot("x", "y", data())
    # Use typst to explicitly style the title and labels ――――――――――――――――――――――――――――――――
    |> XYPlot.put_title("A. Reaction time according to group", text: [weight: "bold"])
    |> XYPlot.put_axis_label("y", "Reaction time (ms)", text: [weight: "bold"])
    |> XYPlot.put_axis_label("x", "Populations", text: [weight: "bold"])
    # ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
    |> XYPlot.render_to_pdf_file!("examples/box-plot-example-with-styled-labels-and-title.pdf")
  end


  def run_without_spines() do
    # The Playfair.Plot2D.XYPlot module contains pretty much everything
    # related to 2D plots with cartesian coordinates in which the X and Y axes
    # are perpendicular
    alias Playfair.Plot2D.XYPlot
    # Import a special sigil to allow us to write length units in a natural way
    import Playfair.Length, only: [sigil_L: 2]
    alias Playfair.Config

    # Ensure deterministic data
    :rand.seed(:exsplus, {0, 42, 0})
    # norm/2 is a function that returns a random value following
    # a Normal(mu, sigma) distribution
    reaction_times = [
      {"Group A", Enum.map(1..50, fn _ -> norm(500.0, 170.00) end)},
      {"Group B", Enum.map(1..60, fn _ -> norm(400.0, 100.0) end)},
      {"Group C", Enum.map(1..30, fn _ -> norm(790.0, 60.0) end)},
      {"Group D", Enum.map(1..80, fn _ -> norm(500.0, 150.0) end)},
    ]

    options = %{
      # The Ubuntu font ships by default with ExTypst
      text_font: "Ubuntu",
      # By setting the text size, we automatically set the size
      # for most text elements in the plot
      # (i.e. titles, axis labels, tick labels, etc)
      # NOTE: this uses a special sigil that allows us to define
      # lengths that mix different units in a way that's correctly
      # interpreted by the Typst backend.
      text_size: ~L[9pt],
      # We can set the label size specifically, and it will
      # override the `text_size` attribute
      major_tick_label_size: ~L[8pt],
      # By default the text weight is medium...
      text_weight: "medium",
      # But we can overwrite it for default plot elements
      plot_title_weight: "bold",
      axis_label_weight: "bold"
    }

    # Note that we don't need to build special structures to hold our text.
    # We can use normal strings, and Playfair will take care of applying
    # the default styles. By default, strings are escaped, but that
    # can be overriden too
    Config.with_options(options, fn ->
      XYPlot.new()
      |> XYPlot.boxplot("x", "y", reaction_times)
      |> XYPlot.put_title("A. Reaction time according to group")
      |> XYPlot.put_axis_label("y", "Reaction time (ms)")
      |> XYPlot.put_axis_label("x", "Populations")
      # Drop the lines of the "x2" (top) and "y2" (right) axes.
      # These axes are added by default to the XYPlot, but actually
      # any number of axes can be added in any location.
      |> XYPlot.drop_axes_spines(["x2", "y2"])
      |> XYPlot.render_to_pdf_file!("examples/box-plot-example-without-spines.pdf")
    end)
  end

  def run() do
    # run_barebones()
    # run_with_labels()
    # run_with_title()
    # run_with_styled_labels_and_title()
    run_without_spines()
  end
end

Playfair.Examples.BoxPlotExamples.run()
