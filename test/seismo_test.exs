defmodule SeismoTest do
  use ExUnit.Case
  doctest Seismo

  test "greets the world" do
    assert Seismo.hello() == :world
  end
end
