defmodule Lists do

  def double(n) do
    2*n
  end

  def five(n) do
    n+5       #Try [2, 4, 5, 6]
  end

  def animal(:dog) do
    :fido
  end
  def animal(n) do
    n
  end

  def double_five_animal([], _) do [] end
  def double_five_animal([h|t], x) do
    case x do
      :double ->
        [double(h)|double_five_animal(t, x)]
      :five ->
        [five(h)|double_five_animal(t, x)]
      :animal ->
        [animal(h)|double_five_animal(t, x)]
    end
  end



  #First define the functions:
  # f = fn(x) -> x * 2 end
  # g = fn(x) -> x + 5 end
  # h = fn(x) -> if x == :dog, do: :fido, else: x end
  def apply_to_all([], _) do [] end
  def apply_to_all([n|t], func) do
    [func.(n)|apply_to_all(t, func)]
  end



  def sum([]) do 0 end
  def sum([h|t]) do
    h + sum(t)
  end

  def prod([], b) do b end
  def prod([h|t], b) do
    h * prod(t, b)
  end

  #First define the functions:
  # sum = fn(x,y) -> x + y end
  # prod = fn(x,y) -> x * y end
  def fold_right([], b, _) do b end
  def fold_right([h|t], b, f ) do
    f.(h, fold_right(t, b, f))
  end

  def fold_left([], b, _) do b end
  def fold_left([h|t], b, f) do
    fold_left(t, f.(h, b), f)
  end


  def odd([]) do [] end
  def odd([h|t]) do
    if (rem(h,2) == 1) do
      [h|odd(t)]
    else
      odd(t)
    end
  end


  #First define the functions:
  # even = fn(x) -> rem(x,2) == 0 end
  # odd = fn(x) -> rem(x,2) == 1 end
  # greater_than_five = fn(x) -> x > 5 end
  def filter([], _) do [] end
  def filter([h|t], f) do
    if (f.(h)) do
      [h|filter(t, f)]
    else
      filter(t, f)
    end
  end



end
