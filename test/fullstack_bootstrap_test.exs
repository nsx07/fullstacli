defmodule FullstackBootstrapTest do
  use ExUnit.Case
  doctest FullstackBootstrap

  test "greets the world" do
    assert FullstackBootstrap.hello() == :world
  end
end
