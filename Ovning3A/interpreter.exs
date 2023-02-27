defmodule Env do
  @type id :: atom()
  @type str :: any()
  @type ids :: [id]

  def new(), do: []

  def add(id, str, []) do [{id, str}] end
  def add(id, str, [{id, _}|t]) do [{id, str}|t] end
  def add(id, str, [h|t]) do [h|add(id, str, t)] end

  def lookup(_, []) do nil end
  def lookup(id, [{id, str}|_]) do {id, str} end
  def lookup(id, [_|t]) do lookup(id, t) end

  def remove(_, []) do [] end
  def remove(ids, [{id, str}|t]) do
    if Enum.member?(ids, id) do
      remove(ids, t)
    else
      [{id, str}|remove(ids, t)]
    end
  end

  def closure(keyss, env) do
    List.foldr(keyss, [], fn(key, acc) ->
      case acc do
        :error ->
          :error

        cls ->
          case lookup(key, env) do
            {key, value} ->
              [{key, value} | cls]

            nil ->
              :error
          end
      end
    end)
  end

  def test() do
    List.foldr([:q, :y, :w, :x], [], fn(key, acc) -> case acc do
        :error ->
          IO.write("U error\n")
          :error

        cls ->
          IO.write("Key: #{inspect(key)}\nAcc: #{inspect(acc)}\n")
          case lookup(key, [{:x, 3}, {:z, 4}]) do
            {key, value} ->
              IO.write("D succeed\n")
              [{key, value} | cls]

            nil ->
              IO.write("D error\n")
              :error
          end
      end
    end)
  end

  def args(pars, args, env) do
    List.zip([pars, args]) ++ env
  end


end

defmodule Eager do
  def test1() do
    env = Env.new()
    env = Env.add(:x, 7, env)
    env = Env.add(:y, 3, env)
    env = Env.add(:z, 5, env)
    exp = {:cons, {:var, :x}, {:cons, {:atm, :e}, {:var, :z}}}
    IO.write("Defined environment: #{inspect(env)}\n")
    IO.write("Expression: #{inspect(exp)}\n")

    evaEx = eval_expr(exp, env)
    IO.write("Evaluate expression: #{inspect(evaEx)}\n")

    datastruct = {7, :e, 5}
    evaMa = eval_match(exp, datastruct, env)
    IO.write("Evaluate match: #{inspect(evaMa)}\n")
  end

  def test2() do
    seq = [{:match, {:var, :x}, {:atm,:a}},
            {:match, {:var, :y}, {:cons, {:var, :x}, {:atm, :b}}},
            {:match, {:cons, :ignore, {:var, :z}}, {:var, :y}},
            {:var, :z}]

    Eager.eval(seq)
  end

  def test3() do
    seq = [{:match, {:var, :x}, {:atm, :a}},
            {:case, {:var, :x},
              [{:clause, {:atm, :b}, [{:atm, :ops}]},
              {:clause, {:atm, :a}, [{:atm, :yes}]}
              ]}
          ]

    Eager.eval(seq)
  end

  def test4() do
    seq = [{:match, {:var, :x}, {:atm, :a}},
            {:match, {:var, :f},
              {:lambda, [:y], [:x], [{:cons, {:var, :x}, {:var, :y}}]}},
            {:apply, {:var, :f}, [{:atm, :b}]}
          ]

    Eager.eval(seq)
  end

  def test5() do
    seq = [{:match, {:var, :x},
            {:cons, {:atm, :a}, {:cons, {:atm, :b}, {:atm, []}}}},
           {:match, {:var, :y},
            {:cons, {:atm, :c}, {:cons, {:atm, :d}, {:atm, []}}}},
            {:apply, {:fun, :append}, [{:var, :x}, {:var, :y}]}
          ]

    Eager.eval(seq)
  end




  def eval(seq) do
    eval_seq(seq, Env.new)
  end


  def eval_seq([exp], env) do
    eval_expr(exp, env)
  end

  def eval_seq([{:match, ptr, exp} | seq], env) do
    case eval_expr(exp, env) do               #Gives us the datastructure of what's on the right hand side (exp), {:var, :x} + [{x: 3}] -> "str" = 3
      :error ->                               #So if the expression would be the variable :x, and :x has the value of 3 in the environment,
        :error                                #then we get {:ok, 3}, which means "str" = 3.
      {:ok, str} ->
        IO.write("str: #{inspect(str)}\n")
        env = eval_scope(ptr, env)            #Extracts variables from "ptr" and then uses them to remove thoose variables from the environment if they exist, since if they
                                              #do we want to be able to overwrite that variable "ptr"={:var, :y} & "env"=[:x, :a]  we wouldn't remove anything and "env" would remain the same.
        case eval_match(ptr, str, env) do     #Since the variable in "ptr" won't be a part of "env", the nil Case for lookup will succeed and
          :fail ->                            #the variable in "ptr" will get the datastructure "str" and added to the environment "env"
            :error

          {:ok, env} ->
            eval_seq(seq, env)                #We use the new updated "env" with the continued part of the sequence
        end
    end
  end



  def eval_expr({:atm, id}, _) do
    {:ok, id}
  end

  def eval_expr({:var, id}, env) do
    case Env.lookup(id, env) do
      nil ->
        :error
      {_, str} ->
        {:ok, str}
    end
  end

  def eval_expr({:cons, he, te}, env) do
    case eval_expr(he, env) do
      :error ->           #Om vi får returnerat error, så är det error
        :error

      {:ok, hs} ->         #Om vi får returnerat detta, så blir det ett nytt case
        case eval_expr(te, env) do
          :error ->
            :error
          {:ok, ts} ->
            {:ok, {hs, ts}}
        end
    end
  end

  def eval_expr({:case, expr, cls}, env) do
    case eval_expr(expr, env) do
      :error ->
        :error

      {:ok, str} ->
        eval_cls(cls, str, env)
    end
  end

  def eval_expr({:lambda, par, free, seq}, env) do
    case Env.closure(free, env) do          #Checks that all free variables are defined in the environment, if they are, it will return a list with the variables and their datastructure. Otherwise it returns ":error"
      :error ->
        :error
      closure ->
        {:ok, {:closure, par, seq, closure}}    #||| "str" = {:closure, [:y], [{:cons, {:var, :x}, {:var, :y}}], [x: a]} |||
    end                                         #environment kommer bli: [x: :a, f: {:closure, [y], [{:cons, {:var, :x}, {:var, :y}}], [x: a]}]
  end

  def eval_expr({:apply, expr, args}, env) do
    case eval_expr(expr, env) do
      :error ->
        :error

      {:ok, {:closure, par, seq, closure}} ->
        case eval_args(args, env) do
          :error ->
            :error

          {:ok, strs} ->
            env = Env.args(par, strs, closure)      # ||| Env.args([:y], [:b], [x: :a])   ->    env = [y: :b, x: :a]
            eval_seq(seq, env)
        end
    end
  end

  def eval_expr({:fun, id}, env) do
    {par, seq} = apply(Prgm, id, [])
    {:ok, {:closure, par, seq, Env.new()}}
    end



  def eval_match(:ignore, _, env) do
    {:ok, env}
  end

  def eval_match({:atm, id}, id, env) do
    {:ok, env}
  end

  def eval_match({:var, id}, str, env) do
    case Env.lookup(id, env) do
      nil ->
        {:ok, Env.add(id, str, env)}

      {_, ^str} ->          #^str för att vi vill minnas vad str är för något när vi har hämtat den, utan hatt-operatorn så kommer den glömma vad som var bundet till den
        {:ok, env}

      {_, _} ->
        :fail
    end
  end

  def eval_match({:cons, hp, tp}, {hs, ts}, env) do
    case eval_match(hp, hs, env) do
      :fail ->
        :fail                         #Om head inte matchar med den första data structuren, så failar den.

      {:ok, env} ->                 #Det här är då en nya env, man skulle kunna skriva det som "env2" för tydlighet
        eval_match(tp, ts, env)       #Om head matchade med den första data structuren så återkallar man match functionen på resten av tail:en, då pattern:en kan vara en lista så då kommer den matcha med ":cons" klausubeln
    end
  end

  def eval_match(_, _, _) do
    :fail
  end



  def eval_scope(ptr, env) do
    Env.remove(extract_vars(ptr), env)
  end



  def extract_vars(pattern) do
    extract_vars(pattern, [])
  end


  def extract_vars({:atm, _}, vars) do vars end
  def extract_vars(:ignore, vars) do vars end
  def extract_vars({:var, var}, vars) do
    [var | vars]
  end
  def extract_vars({:cons, head, tail}, vars) do
    extract_vars(tail, extract_vars(head, vars))
  end



  def eval_cls([], _, _) do
    :error
  end

  def eval_cls([{:clause, ptr, seq} | cls], str, env) do
    case  eval_match(ptr, str, eval_scope(ptr, env)) do
      :fail ->
        eval_cls(cls, str, env)

      {:ok, env} ->
        eval_seq(seq, env)
    end
  end



  def eval_args(args, env) do
    eval_args(args, env, [])
  end

  def eval_args([], _, strs) do {:ok, Enum.reverse(strs)}  end

  def eval_args([expr | exprs], env, strs) do
    case eval_expr(expr, env) do
      :error ->
        :error
      {:ok, str} ->
        eval_args(exprs, env, [str|strs])
    end
  end

end


defmodule Prgm do
  def append() do
    {[:x, :y],
      [{:case, {:var, :x},
        [{:clause, {:atm, []}, [{:var, :y}]},
        {:clause, {:cons, {:var, :hd}, {:var, :tl}},
          [{:cons,
            {:var, :hd},
            {:apply, {:fun, :append}, [{:var, :tl}, {:var, :y}]}}]
        }]
    }]
  }
  end

end
