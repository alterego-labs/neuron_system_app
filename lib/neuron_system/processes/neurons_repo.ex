defmodule NeuronSystem.Processes.NeuronsRepo do
  @moduledoc """
  Neurons registry for the concrete neuron Net.

  This repo is different for each Net and it will be automatically started
  after a new Net is created. Also the new repo will be added to the supervisor tree of the Net.
  """

  use GenServer

  alias NeuronSystem.Models

  def start_link(_defaults \\ :empty) do
    GenServer.start_link(__MODULE__, %{})
  end

  @doc """
  Adds the given neuron to the registry.

  ## Examples

  ```elixir
  neuron_model = Models.Neuron.build(activation_function)
  {:ok, worker_spec} = NeuronSystem.Utils.SpecHelper.build_neuron_worker_spec(neuron_model)
  {:ok, pid} = Supervisor.start_child(net_pid, worker_spec)
  NeuronSystem.Processes.NeuronsRepo.add(repo_pid, {neuron_model, pid})
  ```
  """
  @spec add(pid, {Models.Neuron.t, pid}) :: :ok
  def add(repo_pid, {%Models.Neuron{} = neuron_model, pid}) do
    GenServer.cast(repo_pid, {:add, neuron_model, pid})
  end

  @doc """
  Fetches an information about a neuron by its ID
  """
  @spec get(pid, binary) :: {pid, Models.Neuron.t}
  def get(repo_id, neuron_id) do
    GenServer.call(repo_pid, {:get, neuron_id})
  end

  @spec handle_call({:add, Models.Neuron.t, pid}, any, list) :: {:noreply, any}
  def handle_cast({:add, %Models.Neuron{id: worker_id}, pid}, state) do
    new_state = Map.put(state, worker_id, pid)
    {:noreply, new_state}
  end

  def handle_call({:get, neuron_id}) do
    
  end
end

