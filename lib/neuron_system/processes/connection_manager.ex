defmodule NeuronSystem.Processes.ConnectionManager do
  use GenServer

  def start_link(_defaults \\ :empty) do
    GenServer.start_link(__MODULE__, [])
  end

  @spec handle_call({:add, NeuronSystem.Models.Connection.t}, any, list) :: any
  def handle_call({:add, connection}, _from, state) do
    new_state = [connection | state]
    {:reply, :ok, new_state}
  end
end
