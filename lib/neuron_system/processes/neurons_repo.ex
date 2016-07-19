defmodule NeuronSystem.Processes.NeuronsRepo do
  use GenServer

  alias NeuronSystem.Models

  def start_link(_defaults \\ :empty) do
    GenServer.start_link(__MODULE__, %{})
  end

  @spec handle_call({:add, Models.Neuron.t, pid}, any, list) :: any
  def handle_call({:add, %Models.Neuron{id: worker_id}, pid}, _from, state) do
    new_state = Map.put(state, worker_id, pid)
    {:reply, :ok, new_state}
  end
end

