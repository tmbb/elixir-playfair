defmodule Playfair.DataPlot do
  alias Playfair.Typst, as: T

  defstruct data: %{},
            x_axis: "x",
            y_axis: "y",
            plotter: nil,
            style: %{__style__: nil}

  def to_typst(%__MODULE__{} = data_plot) do
    T.to_typst(%{
      data: data_plot.data,
      "x-axis": data_plot.x_axis,
      "y-axis": data_plot.y_axis,
      plotter: data_plot.plotter,
      style: data_plot.style,
    })
  end

  defp clamp(x, minimum, maximum) do
    min(max(x, minimum), maximum)
  end

  defp normals(n) do
    for _i <- 1..n, do: clamp(:rand.normal(0.5, 0.07), 0.0, 1.0)
  end

  def example() do
    alias Playfair.Typst.Serializer

    data_plot = %__MODULE__{
      data: %{
        x: normals(35),
        y: normals(35)
      },
      x_axis: "x",
      y_axis: "y",
      plotter: :scatterplot,
      style: %{}
    }

    data_plot
    |> to_typst()
    |> Serializer.serialize()
    |> IO.puts()
  end
end
