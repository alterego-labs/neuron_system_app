defmodule NeuronSystem.Processes.ConnectionManager do
  use GenServer

  alias NeuronSystem.Models

  def start_link(_defaults \\ :empty) do
    GenServer.start_link(__MODULE__, [])
  end

  @spec add(pid, Models.Connection.t) :: :ok
  def add(manager_pid, %Models.Connection{} = connection_model) do
    GenServer.cast(manager_pid, {:add, connection_model})
  end

  @spec handle_cast({:add, NeuronSystem.Models.Connection.t}, list) :: any
  def handle_cast({:add, connection}, state) do
    new_state = [connection | state]
    {:noreply, new_state}
  end
end
