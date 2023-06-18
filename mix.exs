defmodule Playfair.MixProject do
  use Mix.Project

  def project do
    [
      app: :playfair,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_typst, "~> 0.1"},
      {:decimal, "~> 2.0"},
      {:statistics, "~> 0.6.2", only: :dev},
      {:ex_doc, "~> 0.29", only: :dev}
    ]
  end
end
