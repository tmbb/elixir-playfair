defmodule Playfair.Examples.BoxPlotExamples do
  alias Playfair.Plot2D.XYPlot
  alias Playfair.Plot2D.XYPlot.BoxPlot
  alias Playfair.Typst

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
    |> BoxPlot.plot("x", "y", data())
    |> XYPlot.render_to_pdf_file!("examples/box-plot-example-barebones.pdf")
  end

  def run_with_labels() do
    XYPlot.new()
    |> BoxPlot.plot("x", "y", data())
    # Add labels to the X and Y axes
    |> XYPlot.put_axis_label("y", "Reaction time (ms)")
    |> XYPlot.put_axis_label("x", "Populations")
    |> XYPlot.render_to_pdf_file!("examples/box-plot-example-with-labels.pdf")
  end

  def run_with_title() do
    XYPlot.new()
    |> BoxPlot.plot("x", "y", data())
    # Add a title to the plot
    |> XYPlot.put_title("A. Reaction time according to group")
    |> XYPlot.put_axis_label("y", "Reaction time (ms)")
    |> XYPlot.put_axis_label("x", "Populations")
    |> XYPlot.render_to_pdf_file!("examples/box-plot-example-with-title.pdf")
  end

  def run_with_styled_labels_and_title() do
    XYPlot.new()
    |> BoxPlot.plot("x", "y", data())
    # Use typst to explicitly style the title and labels
    |> XYPlot.put_title(Typst.raw("strong()[A. Reaction time according to group]"))
    |> XYPlot.put_axis_label("y", Typst.raw("strong()[Reaction time (ms)]"))
    |> XYPlot.put_axis_label("x", Typst.raw("strong()[Populations]"))
    |> XYPlot.drop_axes_spines(["x2", "y2"])
    |> XYPlot.render_to_pdf_file!("examples/box-plot-example-with-styled-labels-and-titles.pdf")
  end

  def run_without_spines() do
    XYPlot.new()
    |> BoxPlot.plot("x", "y", data())
    |> XYPlot.put_title(Typst.raw("strong()[A. Reaction time according to group]"))
    |> XYPlot.put_axis_label("y", Typst.raw("strong()[Reaction time (ms)]"))
    |> XYPlot.put_axis_label("x", Typst.raw("strong()[Populations]"))
    # Drop the spines for the X2 and Y2 axes (you can also remove those axes instead)
    |> XYPlot.drop_axes_spines(["x2", "y2"])
    |> XYPlot.render_to_pdf_file!("examples/box-plot-example-without-spines.pdf")
  end

  def run() do
    run_barebones()
    run_with_labels()
    run_with_title()
    run_with_styled_labels_and_title()
    run_without_spines()
  end
end

Playfair.Examples.BoxPlotExamples.run()
