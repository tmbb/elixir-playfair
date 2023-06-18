defmodule Playfair.Axis.Scale do
  @callback init(list()) :: {Module.t(), list()}

  @callback scale(
              value :: float(),
              min_value :: float(),
              max_value :: float(),
              args :: list()
            ) :: float()
end
