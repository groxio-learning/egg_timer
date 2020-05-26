defmodule EggTimerTest do
  use ExUnit.Case
  doctest EggTimer

  test "greets the world" do
    assert EggTimer.hello() == :world
  end
end
