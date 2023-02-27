defmodule Chopstick do
  def start do
    stick = spawn_link(fn -> available() end)
    stick
  end

  def available() do
    #IO.write("I'm available\n")
    receive do
      {:request, from} ->
        send(from, :granted)
        gone()
      :quit ->
        :ok
    end
  end

  def gone() do
    #IO.write("I'm gone\n")
    receive do
      :return ->
        available()
      :quit ->
        :ok
    end
  end


  def request(stick) do
    send(stick, {:request, self()})
    receive do
      :granted -> :ok
    end
  end

  def return(stick) do
    send(stick, :return)
  end

  def quit(stick) do
    send(stick, :quit)
  end


  # Prevent deadlocks
  def request(stick, timeout) when is_number(timeout) do
    send(stick, {:request, self()})
    receive do
      :granted -> :ok
    after
      timeout -> :no
    end
  end
end









defmodule Philosopher do
  @dreaming 800
  @eating 500
  @delay 500

  def start(hunger, left, right, name, ctrl) do
    spawn_link(fn -> dreaming(hunger, left, right, name, ctrl) end)
  end

  def dreaming(0, _, _, name, ctrl) do
    #IO.puts("********#{name} is finished eating********")
    send(ctrl, :done)
  end

  ## Requests chopsticks one at a time
  def dreaming(hunger, left, right, name, ctrl) do
    #IO.puts("#{name} is dreaming")
    sleep(@dreaming)
    waiting(hunger, left, right, name, ctrl)
  end

  # def waiting(hunger, left, right, name, ctrl) do
  #   IO.puts("#{name} is waiting, #{hunger} to go!")

  #   case Chopstick.request(left) do
  #     :ok ->
  #       IO.puts("#{name} received left stick")
  #       sleep(@delay)

  #       case Chopstick.request(right, 1000) do
  #         :ok ->
  #           IO.puts("#{name} received right stick")
  #           eating(hunger, left, right, name, ctrl)
  #         :no ->
  #           Chopstick.return(left)
  #           Chopstick.return(right)
  #           IO.puts("#{name} waited to long and dropt the left stick")
  #           dreaming(hunger, left, right, name, ctrl)
  #       end
  #   end
  # end

  def waiting(hunger, left, right, name, ctrl) do
    #IO.puts("#{name} is waiting, #{hunger} to go!")

    case {Chopstick.request(left, 300), Chopstick.request(right, 300)} do
      {:ok, :ok} ->
        #IO.puts("#{name} received both sticks")
        eating(hunger, left, right, name, ctrl)
      {_,_} ->
        Chopstick.return(left)
        Chopstick.return(right)
        #IO.puts("#{name} didn't receive the chopsticks")
        waiting(hunger, left, right, name, ctrl)
      # {:no, :ok} ->
      #   IO.puts("#{name} only received right stick, return chopstick")
      #   Chopstick.return(right)
      #   waiting(hunger, left, right, name, ctrl)
      # {:ok, :no} ->
      #   IO.puts("#{name} only received left stick, return chopstick")
      #   Chopstick.return(left)
      #   waiting(hunger, left, right, name, ctrl)
      # {:no, :no} ->
      #   IO.puts("#{name} received none")
      #   waiting(hunger, left, right, name, ctrl)
    end
  end

  def eating(hunger, left, right, name, ctrl) do
    sleep(@eating)
    #IO.puts("#{name} has eaten")
    Chopstick.return(left)
    Chopstick.return(right)

    dreaming(hunger-1, left, right, name, ctrl)
  end


  def sleep(0) do :ok end
  def sleep(t) do
    :timer.sleep(:rand.uniform(t))
  end

end






defmodule Dinner do
  def start(n) do
    t1 = :erlang.timestamp();
    spawn(fn -> init(n, t1) end)
  end

  def init(n, t1) do
    c1 = Chopstick.start()
    c2 = Chopstick.start()
    c3 = Chopstick.start()
    c4 = Chopstick.start()
    c5 = Chopstick.start()
    ctrl = self()
    Philosopher.start(n, c1, c2, "Arendt", ctrl)
    Philosopher.start(n, c2, c3, "Hypatia", ctrl)
    Philosopher.start(n, c3, c4, "Simone", ctrl)
    Philosopher.start(n, c4, c5, "Elisabeth", ctrl)
    Philosopher.start(n, c5, c1, "Ayn", ctrl)
    wait(5, [c1, c2, c3, c4, c5], t1)
  end

  def wait(0, chopsticks, t1) do
    Enum.each(chopsticks, fn(c) -> Chopstick.quit(c) end)
    t2 = :erlang.timestamp();

    IO.puts("----------------FINITO----------------")
    IO.puts("#{:timer.now_diff(t2, t1)}")
  end

  def wait(n, chopsticks, t1) do
    receive do
      :done ->
        wait(n - 1, chopsticks, t1)
      :abort ->
        Process.exit(self(), :kill)
    end
  end
end
