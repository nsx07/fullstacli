defmodule FullstackBootstrap.MixProject do
  use Mix.Project

  def project do
    [
      app: :fullstack_bootstrap,
      version: "0.1.0",
      escript: [main_module: FullstackBootstrap],
      start_permanent: Mix.env() == :prod,
      deps: []
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end
end
