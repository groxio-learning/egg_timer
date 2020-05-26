defmodule EggTimer.Server do
  use GenServer
  alias EggTimer.Alarm
  
  def start_link(timers) when is_map(timers) do
    GenServer.start_link(__MODULE__, timers)
  end

  def init(timers) do
    {:ok, timers}
  end
  
  def handle_info({:alarm, name}, timers) do
    Alarm.trigger(timers[name])
    new_timers = Map.delete(timers, name)
    
    {:noreply, new_timers}
  end
  
  def handle_cast({:schedule, name, duration, f}, timers) do
    alarm = Alarm.new(name, duration, f)
    schedule(self(), alarm)
    
    {:noreply, Map.put(timers, alarm.name, alarm)}
  end
  
  def handle_cast(:stop, timers) do
    # something goes wrong
    {:stop, :we_broke_something, timers}
  end
  
  def handle_call(:status, _from, timers) do
    status = 
      timers 
      |> Enum.map(fn {_name, alarm} -> Alarm.status(alarm) end)
      
    {:reply, status, timers}
  end
  
  def schedule(pid, alarm) do
    Process.send_after(pid, {:alarm, alarm.name}, alarm.duration)
    :ok
  end
end
