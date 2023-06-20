defmodule Playfair.Color.RGB do
  defstruct r: 0,
            b: 0,
            g: 0,
            a: 0

  require Playfair.Color.RGB.FunctionBuilder, as: FunctionBuilder
  FunctionBuilder.build_functions()
end
