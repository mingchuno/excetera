defmodule Excetera.Mixfile do
  use Mix.Project

  def project do
    [
      app: :excetera,
      version: "0.0.2",
      elixir: "~> 1.2.0",
      deps: deps
    ]
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
      {:poison, "~> 2.0"}
    ]
  end
end
