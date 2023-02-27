defmodule Shunt do
  def find([], []), do: []
  def find(x, [hy|ty]) do
    {hs, ts} = Train.split(x, hy)
    [{:one, length(ts)+1}, {:two, length(hs)}, {:one, -length(ts)-1}, {:two, -length(hs)} | find(Train.append(hs, ts), ty)]
  end

  def few([], []), do: []
  def few([h|tx], [h|ty]) do
    few(tx, ty)
  end
  def few(x, [hy|ty]) do
    {hs, ts} = Train.split(x, hy)
    hl = length(hs)
    tl = length(ts)
    [{:one, tl+1}, {:two, hl}, {:one, -tl-1}, {:two, -hl} | few(Train.append(hs, ts), ty)]
  end

  def compress(ms) do
    ns = rules(ms)
    if ns == ms do
      ms
    else
      compress(ns)
    end
  end

  def rules ([]) do [] end
  def rules([{_, 0}|t]) do
    rules(t)
  end
  def rules([{state, n}, {state, m}|t]) do
    rules([{state, n+m}|t])
  end
  def rules([h|t]) do
    [h|rules(t)]
  end

end
