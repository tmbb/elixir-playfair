defmodule Playfair.Scales.LogarithmicScale do
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
    corrected_value = max(value, 0.0001)
    corrected_max = max(max_value, 0.0001)
    corrected_min = max(min_value, 0.0001)

    log_value = :math.log(corrected_value)
    log_max = :math.log(corrected_max)
    log_min = :math.log(corrected_min)

    (log_value - log_min) / (log_max - log_min)
  end
end
