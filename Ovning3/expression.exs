defmodule Expr do
    #  c("expression.exs")         Expr.test()
  @type literal() :: {:num, number()}
  | {:var, atom()}
  | {:q, number(), number()}

  @type expr() :: {:add, expr(), expr()}
  | {:sub, expr(), expr()}
  | {:mul, expr(), expr()}
  | {:div, expr(), expr()}
  | literal()

  def test1() do
    a = {:add, {:mul, {:num, 4}, {:var, :x}}, {:num, 3}}
    map = Envir.new([{:x, 7}, {:y, 3}, {:z, 5}])
    c = eval(a, map)

    IO.write("Defined variables: #{inspect(map)}\n ")
    IO.write("\n#{pprint(a)} = #{c}\n")
  end

  def test2() do
    a = {:add, {:add, {:mul, {:div, {:num, 3}, {:num, 4}}, {:var, :x}}, {:num, 3}}, {:mul, {:mul, {:div, {:num, 3}, {:num, 7}}, {:var, :y}}, {:num, 2}}}
    map = Envir.new([{:x, 7}, {:y, 3}, {:z, 5}])
    c = eval(a, map)

    IO.write("Defined variables: #{inspect(map)}\n ")
    IO.write("\n#{pprint(a)} = #{pprint(c)}\n")
  end


  def eval({:num, n}, _) do n end
  def eval({:var, v}, map) do Envir.lookup(map, v) end
  def eval({:add, e1, e2}, map) do
    add(eval(e1, map), eval(e2, map))
  end
  def eval({:sub, e1, e2}, map) do
    sub(eval(e1, map), eval(e2, map))
  end
  def eval({:mul, e1, e2}, map) do
    mul(eval(e1, map), eval(e2, map))
  end
  def eval({:div, e1, e2}, map) do
    divide(eval(e1, map), eval(e2, map))
  end


  def add({:q, n1, m1}, {:q, n2, m2}) do
    fungcd({:q, (n1*m2)+(n2*m1), m1*m2})
  end
  def add({:q, n, m}, v2) do
    fungcd({:q, n+(v2*m), m})
  end
  def add(v1, {:q, n, m}) do
    fungcd({:q, n+(v1*m), m})
  end
  def add(v1, v2) do v1+v2 end

  def sub({:q, n1, m1}, {:q, n2, m2}) do
    fungcd({:q, (n1*m2)-(n2*m1), m1*m2})
  end
  def sub({:q, n, m}, v2) do
    fungcd({:q, n-(v2*m), m})
  end
  def sub(v1, {:q, n, m}) do
    fungcd({:q, (v1*m)-n, m})
  end
  def sub(v1, v2) do v1-v2 end

  def mul({:q, n1, m1}, {:q, n2, m2}) do
    fungcd({:q, n1*n2, m1*m2})
  end
  def mul({:q, n, m}, v2) do
    fungcd({:q, n*v2, m})
  end
  def mul(v1, {:q, n, m}) do
    fungcd({:q, n*v1, m})
  end
  def mul(v1, v2) do v1*v2 end

  def divide({:q, n1, m1}, {:q, n2, m2}) do
    fungcd({:q, n1*m2, m1*n2})
  end
  def divide({:q, n, m}, v2) do
    fungcd({:q, n, m*v2})
  end
  def divide(v1, {:q, n, m}) do
    fungcd({:q, v1*m, n})
  end
  def divide(v1, v2) do {:q, v1, v2} end


  def fungcd({:q, n, m}) do {:q, div(n, Integer.gcd(n, m)), div(m, Integer.gcd(n, m))} end


  def pprint({:num, n}) do "#{n}" end

  def pprint({:var, v}) do "#{v}" end

  def pprint({:q, n, m}) do "(#{n}/#{m})" end

  def pprint({:add, e1, e2}) do "(#{pprint(e1)} + #{pprint(e2)})" end

  def pprint({:sub, e1, e2}) do "(#{pprint(e1)} - #{pprint(e2)})" end

  def pprint({:mul, e1, e2}) do "#{pprint(e1)}*#{pprint(e2)}" end

  def pprint({:div, e1, e2}) do "(#{pprint(e1)}/#{pprint(e2)})" end

  def pprint(n) do "#{n}" end

end

defmodule Envir do
  def new(lst) do lst end

  def lookup([], _) do nil end
  def lookup([{key, value}|_], key) do value end
  def lookup([_|t], key) do lookup(t, key) end
end






# defmodule Expr do
#   #  c("expression.exs")         Expr.test()
# @type literal() :: {:num, number()}
# | {:var, atom()}
# | {:q, number(), number()}

# @type expr() :: {:add, expr(), expr()}
# | {:sub, expr(), expr()}
# | {:mul, expr(), expr()}
# | {:div, expr(), expr()}
# | literal()

# def test1() do
#   a = {:add, {:mul, {:num, 4}, {:var, :x}}, {:num, 3}}
#   map = Envir.new([{:x, 7}, {:y, 3}, {:z, 5}])
#   c = eval(a, map)

#   IO.write("Defined variables: #{inspect(map)}\n ")
#   IO.write("\n#{pprint(a)} = #{c}\n")
# end

# def test2() do
#   a = {:add, {:add, {:mul, {:q, 3, 4}, {:var, :x}}, {:num, 3}}, {:mul, {:mul, {:q, 3, 7}, {:var, :y}}, {:num, 2}}}
#   map = Envir.new([{:x, 7}, {:y, 3}, {:z, 5}])
#   c = eval(a, map)

#   IO.write("Defined variables: #{inspect(map)}\n ")
#   IO.write("\n#{pprint(a)} = #{pprint(c)}\n")
# end


# def eval({:num, n}, _) do n end
# def eval({:var, v}, map) do Envir.lookup(map, v) end
# def eval({:q, n, m}, _) do {:q, n, m} end
# def eval({:add, e1, e2}, map) do
#   add(eval(e1, map), eval(e2, map))
# end
# def eval({:sub, e1, e2}, map) do
#   sub(eval(e1, map), eval(e2, map))
# end
# def eval({:mul, e1, e2}, map) do
#   mul(eval(e1, map), eval(e2, map))
# end
# def eval({:div, e1, e2}, map) do
#   divide(eval(e1, map), eval(e2, map))
# end

# def add({:q, n1, m1}, {:q, n2, m2}) do {:q, (n1*m2)+(n2*m1), m1*m2} end
# def add({:q, n, m}, v2) do {:q, n+(v2*m), m} end
# def add(v1, {:q, n, m}) do {:q, n+(v1*m), m} end
# def add(v1, v2) do v1+v2 end

# def sub({:q, n1, m1}, {:q, n2, m2}) do {:q, (n1*m2)-(n2*m1), m1*m2} end
# def sub({:q, n, m}, v2) do {:q, n-(v2*m), m} end
# def sub(v1, {:q, n, m}) do {:q, (v1*m)-n, m} end
# def sub(v1, v2) do v1-v2 end

# def mul({:q, n1, m1}, {:q, n2, m2}) do {:q, n1*n2, m1*m2} end
# def mul({:q, n, m}, v2) do {:q, n*v2, m} end
# def mul(v1, {:q, n, m}) do {:q, n*v1, m} end
# def mul(v1, v2) do v1*v2 end

# def divide({:q, n1, m1}, {:q, n2, m2}) do {:q, n1*m2, m1*n2} end
# def divide({:q, n, m}, v2) do {:q, n, m*v2} end
# def divide(v1, {:q, n, m}) do {:q, v1*m, n} end
# def divide(v1, v2) do {:q, v1, v2} end


# def pprint({:num, n}) do "#{n}" end

# def pprint({:var, v}) do "#{v}" end

# def pprint({:q, n, m}) do "(#{n}/#{m})" end

# def pprint({:add, e1, e2}) do "(#{pprint(e1)} + #{pprint(e2)})" end

# def pprint({:sub, e1, e2}) do "(#{pprint(e1)} - #{pprint(e2)})" end

# def pprint({:mul, e1, e2}) do "#{pprint(e1)}*#{pprint(e2)}" end

# def pprint({:div, e1, e2}) do "(#{pprint(e1)}/#{pprint(e2)})" end

# def pprint(n) do "#{n}" end

# end
