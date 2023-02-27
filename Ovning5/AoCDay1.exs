defmodule Solution do
  def part1 do
    File.read!("input.txt")
    |> String.split("\n", trim: false)      #Splits the text file into a array of numbers as strings and empty strings.
    |> Enum.reduce([0], fn                  #Creates an array with every elfs total calorie count (+ also a index with value 0)
        ("", elf) ->
          [0|elf]
        (cal, [h|t]) ->
          {num, ""} = Integer.parse(cal)
          [num + h|t]
      end)
    |> Enum.reduce(0, fn(x, acc) ->        #Finds the biggest value in the list
      if x > acc,
        do: x,
        else: acc end)
  end

  def part2 do
    File.read!("input.txt")
    |> String.split("\n", trim: false)
    |> Enum.reduce([0], fn
        ("", elf) ->
          [0|elf]
        (cal, [h|t]) ->
          {num, ""} = Integer.parse(cal)
          [num + h|t]
      end)
    |> Enum.sort(&(&1 >= &2))             #Writes out the list in order from who has the most calories
    |> Enum.take(3)                       #Takes the three first elements
    |> Enum.sum()                         #Sums them all upp
  end

end
