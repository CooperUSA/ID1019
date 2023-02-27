defmodule Hanoi do

  def test() do
    Enum.each(1..10, fn(x) ->
      IO.write("Tower of size #{x} takes #{Enum.count(hanoi(x, :a, :b, :c))} moves\n") end)
  end

  

  def hanoi(0, _, _, _) do [] end

  def hanoi(n, from, aux, to) do
    hanoi(n-1, from, to, aux) ++
    [{:move, from, to}] ++
    hanoi(n-1, aux, from, to)
  end
end
