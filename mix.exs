defmodule Excetera.Mixfile do
  use Mix.Project

  @version "0.0.2"

  def project do
    [
      app: :excetera,
      version: @version,
      elixir: "~> 1.2",
      description: description,
      package: package,
      source_url: "https://github.com/mingchuno/excetera",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
      docs: [extras: ["README.md"], main: "readme",
             source_ref: "v#{@version}",
             source_url: "https://github.com/mingchuno/excetera"]
    ]
  end

  defp description do
    """
    Elixir bindings for etcd's HTTP API.
    """
  end

  def application do
    [
      mod: { Excetera.Application, [] },
      applications: [:httpoison, :poison],
      env: [etcd_url: "http://127.0.0.1:4001/v2/keys"],
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 0.8.0"},
      {:poison, "~> 2.0"},
      {:earmark, "~> 0.2", only: :docs},
      {:ex_doc, "~> 0.11", only: :docs},
      {:inch_ex, "~> 0.5", only: :docs}
    ]
  end

  defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
     maintainers: ["mingchuno"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/mingchuno/excetera"}]
  end
end
