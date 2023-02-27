defmodule Moves do
def single({:one, n}, {m, o ,t}) do
  if n >= 0 do
    {_, m, cart} = Train.main(m, n)
    o = Train.append(cart, o)
    {m, o ,t}
  else
    cart = Train.take(o, -n)
    o = Train.drop(o, -n)
    m = Train.append(m, cart)
    {m, o ,t}
  end
end
def single({:two, n}, {m, o ,t}) do
  if n >= 0 do
    {_, m, cart} = Train.main(m, n)
    t = Train.append(cart, t)
    {m, o ,t}
  else
    cart = Train.take(t, -n)
    t = Train.drop(t, -n)
    m = Train.append(m, cart)
    {m, o ,t}
  end
end

def sequence([], track) do [track] end
def sequence([h|t], track) do
  [track | sequence(t, single(h, track))]
end
end
