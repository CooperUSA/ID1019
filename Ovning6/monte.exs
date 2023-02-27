defmodule Monte do
  def dart(r) do
    x = Enum.random(0..r)
    y = Enum.random(0..r)
    :math.pow(r, 2) > :math.pow(x, 2) + :math.pow(y, 2)
  end

  # k, number of darts
  # r, circle radius
  # a, accumulated value
  def round(0, _, a) do a end
  def round(k, r, a) do
    if dart(r) do
      round(k-1, r, a+1)
    else
      round(k-1, r, a)
    end
  end

  # j, number of rounds
  # k, number of darts
  # r, circle radius
  # t, accumulated sum of all darts
  # a, accumulated value
  def rounds(j, k, r) do
    rounds(j, k, 0, r, 0)
  end

  def rounds(0, _, t, _, a) do 4*a/t end
  def rounds(j, k, t, r, a) do
    a = round(k, r, a)
    t = t + k
    pi = 4*a/t
    :io.format("Our pi:~14.10f,  Diff =~14.10f\n", [pi, pi - :math.pi()])
    rounds(j-1, 2*k, t, r, a)
  end

  def test() do
    rounds(10, 1000000, 1000000)
  end

end

defmodule Leib do
  def leib(n) do
    4 * Enum.reduce(0..n, 0,
      fn(k,a) ->
        a + 1/(4*k + 1) - 1/(4*k + 3)
      end)
  end
end
