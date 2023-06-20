defmodule Playfair.Plot2D.XYPlot do
  alias __MODULE__
  alias Playfair.Plot2D.XYAxis
  alias Playfair.Typst
  alias Playfair.Config
  alias Playfair.Typst.Serializer
  import Playfair.Length, only: [sigil_L: 2]

  @external_resource "priv/templates/xy_plot_template.typ"
  @xy_plot_template File.read!("priv/templates/xy_plot_template.typ")

  defstruct plot_blueprints: [],
            title: nil,
            width: ~L[10cm],
            height: ~L[7cm],
            finalized: false,
            axes: %{
              "x" => XYAxis.new(name: "x", location: :bottom, direction: :ltr),
              "y" => XYAxis.new(name: "y", location: :left, direction: :btt),
              "x2" => XYAxis.new(name: "x2", location: :top, direction: :ltr),
              "y2" => XYAxis.new(name: "y2", location: :right, direction: :btt),
            }

  def put_title(%XYPlot{} = xy_plot, title, opts \\ []) do
    typst_title =
      if is_binary(title) do
        title_text_attrs = Keyword.get(opts, :text, [])
        base_text_attrs = Config.get_plot_title_text_attributes()
        # Merge all attributes
        text_attrs = Keyword.merge(base_text_attrs, title_text_attrs)

        title
        |> Typst.text(text_attrs)
        |> Typst.to_typst()
      else
        Typst.to_typst(title)
      end

    %{xy_plot | title: typst_title}
  end

  def get_axis(%XYPlot{} = xy_plot, name) do
    Map.get(xy_plot.axes, name)
  end

  def put_axis(%XYPlot{} = xy_plot, name, new_axis) do
    %{xy_plot | axes: Map.put(xy_plot.axes, name, new_axis)}
  end

  def update_axis(%XYPlot{} = xy_plot, name, fun) do
    axis = get_axis(xy_plot, name)
    updated_axis = fun.(axis)
    put_axis(xy_plot, name, updated_axis)
  end

  def add_ticks(%XYPlot{} = xy_plot) do
    updated_axes =
      for {name, axis} <- xy_plot.axes, into: %{} do
        updated_axis = XYAxis.add_ticks(axis)
        {name, updated_axis}
      end

    %{xy_plot | axes: updated_axes}
  end

  def delete_axis_spine(%XYPlot{} = xy_plot, name) do
    update_axis(xy_plot, name, fn axis ->
      %{axis | spine: false}
    end)
  end

  def drop_axes_spines(%XYPlot{} = xy_plot, names) do
    Enum.reduce(names, xy_plot, fn name, plot ->
      delete_axis_spine(plot, name)
    end)
  end

  @doc false
  def apply_scales(%XYPlot{} = xy_plot) do
    # Apply scales to data
    scaled_plot_blueprints =
      for plot_blueprint <- xy_plot.plot_blueprints do
        %{
          elixir_plotter: plotter_module,
          x_axis_name: x_axis_name,
          y_axis_name: y_axis_name
        } = plot_blueprint

        x_axis = get_axis(xy_plot, x_axis_name)
        y_axis = get_axis(xy_plot, y_axis_name)

        plot_blueprint = Map.delete(plot_blueprint, :elixir_plotter)

        plotter_module.apply_scale(x_axis, y_axis, plot_blueprint)
      end

    # Apply scales to tick locations
    updated_axes =
      for {name, axis} <- xy_plot.axes, into: %{} do
        new_major_tick_locations = XYAxis.apply_scale_to_many(axis, axis.major_tick_locations)
        updated_axis = %{axis | major_tick_locations: new_major_tick_locations}

        {name, updated_axis}
      end

    %{xy_plot | axes: updated_axes, plot_blueprints: scaled_plot_blueprints}
  end

  def finalize(%XYPlot{} = xy_plot) do
    final_xy_plot =
      xy_plot
      |> set_max_and_min_axes_values()
      |> add_ticks()
      |> apply_scales()
      |> freeze_axes()

    %{final_xy_plot | finalized: true}
  end

  defp max_with_nil(nil, nil), do: nil
  defp max_with_nil(a, nil), do: a
  defp max_with_nil(nil, b), do: b
  defp max_with_nil(a, b), do: max(a, b)

  defp min_with_nil(nil, nil), do: nil
  defp min_with_nil(a, nil), do: a
  defp min_with_nil(nil, b), do: b
  defp min_with_nil(a, b), do: min(a, b)

  defp set_max_and_min_axes_values(%XYPlot{} = xy_plot) do
    plot_blueprints = xy_plot.plot_blueprints
    updated_axes =
      for {name, axis} <- xy_plot.axes, into: %{} do
        {data_min_value, data_max_value} =
          Enum.reduce(plot_blueprints, {nil, nil}, fn blueprint, {current_min, current_max} ->
            cond do
              blueprint.x_axis_name != name and blueprint.y_axis_name != name ->
                {current_min, current_max}

              blueprint.x_axis_name == name ->
                new_min = min_with_nil(blueprint.x_min, current_min)
                new_max = max_with_nil(blueprint.x_max, current_max)

                {new_min, new_max}

              blueprint.y_axis_name == name ->
                new_min = min_with_nil(blueprint.y_min, current_min)
                new_max = max_with_nil(blueprint.y_max, current_max)

                {new_min, new_max}
            end
          end)

        updated_axis =
          axis
          |> XYAxis.put_min_value_if_not_set(data_min_value)
          |> XYAxis.put_max_value_if_not_set(data_max_value)

        {name, updated_axis}
      end

    %{xy_plot | axes: updated_axes}
  end

  defp freeze_axes(%XYPlot{} = xy_plot) do
    axes =
      xy_plot.axes
      |> Enum.map(fn {name, axis} -> {name, XYAxis.freeze(axis)} end)
      |> Enum.into(%{})

    %{xy_plot | axes: axes}
  end

  def new(args \\ []) do
    struct(__MODULE__, args)
  end

  def put_axis_label(%XYPlot{} = xy_plot, name, label, opts \\ []) do
    update_axis(xy_plot, name, fn axis -> XYAxis.put_label(axis, label, opts) end)
  end

  defp separate_axes(axes) do
    separated =
      axes
      |> Map.values()
      |> Enum.group_by(fn axis -> axis.location end)

    separated
  end

  defp to_typst_kwargs(%XYPlot{finalized: true} = xy_plot) do
    separated_axes = separate_axes(xy_plot.axes)
    trimmed_xy_plot = Map.drop(xy_plot, [:__struct__, :axes, :finalized])

    trimmed_xy_plot
    |> Map.put(:top_axes, Map.get(separated_axes, :top, []))
    |> Map.put(:left_axes, Map.get(separated_axes, :left, []))
    |> Map.put(:bottom_axes, Map.get(separated_axes, :bottom, []))
    |> Map.put(:right_axes, Map.get(separated_axes, :right, []))
    |> Typst.map_to_kw_args()
  end

  def render_to_typst(%XYPlot{} = xy_plot) do
    xy_plot
    # Finalize the plot if not finalized already
    |> finalize()
    # Build typst AST
    |> to_typst()
    # Serialize the AST into text, ready to be inserted in a file
    |> Serializer.serialize()
    # Prepend a ?# character so that it can be inserted at the top level
    |> then(fn serialized -> ["#", serialized] end)
    # convert the contents into a binary
    |> IO.iodata_to_binary()
  end

  def render_to_pdf_binary(%XYPlot{} = xy_plot) do
    typst_serialized_plot = render_to_typst(xy_plot)

    # Insert the serialized plot into a template
    typst_file =
      String.replace(
        @xy_plot_template,
        "// $ADD-PLOT-HERE",
        typst_serialized_plot
      )

    # Render the template into PDF
    ExTypst.render_to_pdf(typst_file)
  end

  def render_to_pdf_binary!(%XYPlot{} = xy_plot) do
    {:ok, pdf_binary} = render_to_pdf_binary(xy_plot)
    pdf_binary
  end

  def render_to_pdf_file(%XYPlot{} = xy_plot, path) do
    case render_to_pdf_binary(xy_plot) do
      {:ok, pdf_binary} ->
        File.write(path, pdf_binary)

      error ->
        error
    end
  end

  def render_to_pdf_file!(%XYPlot{} = xy_plot, path) do
    pdf_binary = render_to_pdf_binary!(xy_plot)
    File.write!(path, pdf_binary)
  end

  def to_typst(%XYPlot{} = xy_plot) do
    kw_args = to_typst_kwargs(xy_plot)

    Typst.function_call(
      Typst.variable("plot"),
      kw_args
    )
  end

  # Plot types

  # TODO: Do we really want this module?

  alias Playfair.Plot2D.XYPlot.BoxPlot

  @not_implemented_message "Function not implemented."

  @doc false
  def violin(_x_axis, _y_axis, _data, _opts) do
    raise RuntimeError, @not_implemented_message
  end

  def density(_x_axis, _y_axis, _data, _opts) do
    raise RuntimeError, @not_implemented_message
  end

  def histogram(_x_axis, _y_axis, _data, _opts) do
    raise RuntimeError, @not_implemented_message
  end

  def boxplot(x_axis, y_axis, data, opts \\ []) do
    BoxPlot.plot(x_axis, y_axis, data, opts)
  end

  def ridgeline(_x_axis, _y_axis, _data, _opts) do
    raise RuntimeError, @not_implemented_message
  end

  def scatterplot(_x_axis, _y_axis, _data, _opts) do
    raise RuntimeError, @not_implemented_message
  end

  def heatmap(_x_axis, _y_axis, _data, _opts) do
    raise RuntimeError, @not_implemented_message
  end

  def correlogram(_x_axis, _y_axis, _data, _opts) do
    raise RuntimeError, @not_implemented_message
  end

  def bubble(_x_axis, _y_axis, _data, _opts) do
    raise RuntimeError, @not_implemented_message
  end

  def connected_scatter(_x_axis, _y_axis, _data, _opts) do
    raise RuntimeError, @not_implemented_message
  end

  def density_2d(_x_axis, _y_axis, _data, _opts) do
    raise RuntimeError, @not_implemented_message
  end

  def barplot(_x_axis, _y_axis, _data, _opts) do
    raise RuntimeError, @not_implemented_message
  end

  def radar(_x_axis, _y_axis, _data, _opts) do
    raise RuntimeError, @not_implemented_message
  end

  def word_cloud(_x_axis, _y_axis, _data, _opts) do
    raise RuntimeError, @not_implemented_message
  end

  def parallel(_x_axis, _y_axis, _data, _opts) do
    raise RuntimeError, @not_implemented_message
  end

  def lolipop(_x_axis, _y_axis, _data, _opts) do
    raise RuntimeError, @not_implemented_message
  end

  def circular_barplot(_x_axis, _y_axis, _data, _opts) do
    raise RuntimeError, @not_implemented_message
  end

  def treemap(_x, _y), do: nil

  def venn_diagram(nil), do: nil

  def donut(nil), do: nil
end
