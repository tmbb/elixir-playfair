defmodule Playfair.Typst.Directons do
  alias Playfair.Typst

  def ltr(), do: Typst.variable("ltr")
  def rtl(), do: Typst.variable("rtl")
  def ttb(), do: Typst.variable("ttb")
  def btt(), do: Typst.variable("btt")
end
