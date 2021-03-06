defmodule LearnEcto.MixProject do
  use Mix.Project

  def project do
    [
      app: :learn_ecto,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {LearnEcto.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:postgrex, "~> 0.14"},
      {:ecto, "~> 3.1"},
      {:ecto_sql, "~> 3.1"}
    ]
  end
end
