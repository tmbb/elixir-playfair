defmodule Playfair.Scales.PowerScale do
  @behaviour Playfair.Axis.Scale

  @impl true
  def init(opts) do
    case Keyword.fetch(opts, :exponent) do
      {:ok, _exponent} ->
        :ok

      :error ->
        raise ArgumentError, "The `:exponent` option is required"
    end

    {__MODULE__, opts}
  end

  @impl true
  def scale(_value, min_value, max_value, _opts) when min_value == max_value do
    0.5
  end

  def scale(value, min_value, max_value, opts) do
    exponent = Keyword.fetch!(opts, :exponent)

    exp_value = :math.pow(value, exponent)
    exp_max = :math.pow(max_value, exponent)
    exp_min = :math.pow(min_value, exponent)

    (exp_value - exp_min) / (exp_max - exp_min)
  end
end
