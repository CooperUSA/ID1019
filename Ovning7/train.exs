defmodule Train do
  def take(_, 0), do: []
  def take([h|t], n), do: [h|take(t, n-1)]

  def drop(train, 0), do: train
  def drop([_|t], n), do: drop(t, n-1)

  def append([], train2), do: train2
  def append([h|t], train2), do: [h|append(t, train2)]

  def member([], _), do: false
  def member([h|_], h), do: true
  def member([_|t], y), do: member(t, y)

  def position([h|_], h), do: 1
  def position([_|t], y), do: position(t, y) + 1

  def split([y|t], y), do: {[], t}
  def split([h|t], y) do
    {t, drop} = split(t, y)
    {[h|t], drop}
  end

  def main([], n), do: {n, [], []}
  def main([h|t], n) do
    case main(t, n) do
	    {0, drop, take} ->
	      {0, [h|drop], take}
	    {n, drop, take} ->
	      {n-1, drop, [h|take]}
    end
  end
end
