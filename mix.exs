defmodule FullStacli.MixProject do
  use Mix.Project

  def project do
    [
      app: :fullstacli,
      version: "0.1.0",
      escript: [main_module: FullStacli],
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
