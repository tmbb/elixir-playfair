defmodule Playfair.Scales.LinearScale do
  @behaviour Playfair.Axis.Scale

  @impl true
  def init(_opts \\ []) do
    {__MODULE__, []}
  end

  @impl true
  def scale(_value, min_value, max_value, _opts) when min_value == max_value do
    0.5
  end

  def scale(value, min_value, max_value, _opts) do
    (value - min_value) / (max_value - min_value)
  end
end
