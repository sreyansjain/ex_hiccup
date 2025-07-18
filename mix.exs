defmodule ExHiccup.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_hiccup,
      version: "0.1.1",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "A Hiccup-inspired HTML renderer for Elixir, supporting dot-class/hash-id tag syntax, IO data performance, and safe escaping.",
      package: package(),
      source_url: "https://github.com/sreyansjain/ex_hiccup"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Sreyans Jain"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/sreyansjain/ex_hiccup"},
      files: ~w(lib mix.exs README.md LICENSE*)
    ]
  end
end
