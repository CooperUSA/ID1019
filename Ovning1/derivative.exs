defmodule Derivative do
#c("derivative.exs")         Derivative.test3()
  @type literal() :: {:num, number()}
    | {:var, atom()}

  @type expr() :: {:add, expr(), expr()}
    | {:mul, expr(), expr()}
    | literal()
    | {:exp, expr(), {:num, number()}}
    | {:ln, expr()}
    | {:sin, expr()}
    | {:cos, expr()}



  def test1() do
    a = {:add, {:mul, {:num, 4}, {:var, :x}}, {:num, 3}}
    b = deriv(a, :x)
    c = simp(b)
    IO.write("Expression: #{pprint(a)} \n")
    IO.write("Derivative: #{pprint(b)} \n")
    IO.write("Simplified: #{pprint(c)} \n")
  end

  def test2() do
    a = {:add, {:mul, {:num, 4}, {:exp, {:var, :x}, {:num, -3}}}, {:mul, {:num, 2}, {:var, :x}}}
    b = deriv(a, :x)
    c = simp(b)
    IO.write("Expression: #{pprint(a)} \n")
    IO.write("Derivative: #{pprint(b)} \n")
    IO.write("Simplified: #{pprint(c)} \n")
  end

  def test3() do
    a = {:mul, {:var, :x}, {:add, {:num, 2}, {:ln, {:var, :x}}}}
    b = deriv(a, :x)
    c = simp(b)
    IO.write("Expression: #{pprint(a)} \n")
    IO.write("Derivative: #{pprint(b)} \n")
    IO.write("Simplified: #{pprint(c)} \n")
  end

  def test4() do
    a = {:sin, {:mul, {:num, 2}, {:var, :x}}}
    b = deriv(a, :x)
    c = simp(b)
    IO.write("Expression: #{pprint(a)} \n")
    IO.write("Derivative: #{pprint(b)} \n")
    IO.write("Simplified: #{pprint(c)} \n")
  end


  def deriv({:num, _}, _) do {:num, 0} end

  def deriv({:var, v}, v) do {:num, 1} end

  def deriv({:var, _}, _) do {:num, 0} end

  def deriv({:add, e1, e2}, v) do
    {:add, deriv(e1, v), deriv(e2, v)}
  end

  def deriv({:mul, e1, e2}, v) do
    {:add, {:mul, deriv(e1, v), e2}, {:mul, e1, deriv(e2, v)}}
  end

  #Exponential/Root
  def deriv({:exp, e1, {:num, n}}, v) do
    {:mul,
      {:mul, {:num,n}, {:exp, e1, {:num, n-1}}},
      deriv(e1, v)}
  end

  #Logarithmic
  def deriv({:ln, e}, v) do
    {:mul,
      {:exp, e, {:num, -1}},
      deriv(e, v)}
  end

  #Trigonometric
  def deriv({:sin, e}, v) do
    {:mul,
      {:cos, e},
      deriv(e, v)}
  end
  def deriv({:cos, e}, v) do
    {:mul,
      {:num, -1},
      {:mul,
        {:sin, e},
        deriv(e, v)}}
  end


  def pprint({:num, n}) do "#{n}" end

  def pprint({:var, v}) do "#{v}" end

  def pprint({:add, e1, e2}) do "(#{pprint(e1)} + #{pprint(e2)})" end

  def pprint({:mul, e1, e2}) do "#{pprint(e1)}*#{pprint(e2)}" end

  def pprint({:exp, e1, n}) do "([#{pprint(e1)}]^#{pprint(n)})" end

  def pprint({:ln, e}) do "(ln[#{pprint(e)}])" end

  def pprint({:sin, e}) do "(sin[#{pprint(e)}])" end

  def pprint({:cos, e}) do "(cos[#{pprint(e)}])" end



  def simp({:num, n}) do {:num, n} end

  def simp({:var, v}) do {:var, v} end

  def simp({:add, e1, e2}) do
    simp_add(simp(e1), simp(e2))
  end

  def simp({:mul, e1, e2}) do
    simp_mul(simp(e1), simp(e2))
  end

  def simp({:exp, e1, {:num, n}}) do
    simp_exp(simp(e1), n)
  end

  def simp({:ln, e}) do
    simp_ln(simp(e))
  end

  def simp({:sin, e}) do
    simp_sin(simp(e))
  end

  def simp({:cos, e}) do
    simp_cos(simp(e))
  end

  def simp_add(e1, {:num, 0}) do e1 end
  def simp_add({:num, 0}, e2) do e2 end
  def simp_add({:num, n1}, {:num, n2}) do {:num, n1+n2} end
  def simp_add(e1, e2) do {:add, e1, e2} end

  def simp_mul(_, {:num, 0}) do {:num, 0} end
  def simp_mul({:num, 0}, _) do {:num, 0} end
  def simp_mul({:num, 1}, e2) do e2 end
  def simp_mul(e1, {:num, 1}) do e1 end
  def simp_mul({:num, n1}, {:num, n2}) do {:num, n1*n2} end
  def simp_mul({:var, v}, {:var, v}) do {:exp, {:var, v}, {:num, 2}} end #same variable multiplied together
  def simp_mul({:var, v}, {:exp, {:var, v}, {:num, n}}) do {:exp, {:var, v}, {:num, n+1}} end #same variable multiplied together, but with exponantials
  def simp_mul({:exp, {:var, v}, {:num, n}}, {:var, v}) do {:exp, {:var, v}, {:num, n+1}} end #same variable multiplied together, but with exponantials
  def simp_mul({:mul, {:num, n1}, e1}, {:num, n2}) do {:mul, {:num, n1*n2}, e1} end #Incase there's a multiplication of between a number
  def simp_mul({:mul, e1, {:num, n1}}, {:num, n2}) do {:mul, {:num, n1*n2}, e1} end #and an other multiplication that is made up of a function
  def simp_mul({:num, n1}, {:mul, {:num, n2}, e2}) do {:mul, {:num, n1*n2}, e2} end #and a second number. Then first multiply the numbers
  def simp_mul({:num, n1}, {:mul, e2, {:num, n2}}) do {:mul, {:num, n1*n2}, e2} end #together and then the function
  def simp_mul(e1, e2) do {:mul, e1, e2} end

  def simp_exp(:num, 0) do {:num, 0} end
  def simp_exp(e1, 1) do e1 end
  def simp_exp(e1, n) do {:exp, e1, {:num, n}} end

  def simp_ln({:num, n}) do
    if n>0 do
      {:ln, {:num, n}}
    else
      raise ArgumentError, message: "the argument value is invalid"
    end
  end
  def simp_ln(e) do {:ln, e} end

  def simp_sin({:num, 0}) do {:num, 0} end
  def simp_sin(e) do {:sin, e} end

  def simp_cos({:num, 0}) do {:num, 1} end
  def simp_cos(e) do {:cos, e} end

end
