defmodule Playfair.Typst.Alignments do
  alias Playfair.Typst

  def top(), do: Typst.variable("top")
  def horizon(), do: Typst.variable("horizon")
  def bottom(), do: Typst.variable("bottom")

  def start(), do: Typst.variable("start")
  def end_(), do: Typst.variable("end")
  def center(), do: Typst.variable("center")
  def left(), do: Typst.variable("left")
  def right(), do: Typst.variable("right")
end
