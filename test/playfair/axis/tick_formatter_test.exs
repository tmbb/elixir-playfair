defmodule Test.Playfair.Axis.TickFormatterTest do
  use ExUnit.Case, async: true

  alias Playfair.Formatter

  test "format some numbers" do
    assert Formatter.rounded_float(2.091, 2) == "2.09"
  end

  test "the formatter rounds to the nearest even digit" do
    assert Formatter.rounded_float(7.0825, 3) == "7.082"
  end
end
