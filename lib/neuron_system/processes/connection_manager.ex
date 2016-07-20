defmodule NeuronSystem.Processes.ConnectionManager do
  @moduledoc """
  Represents a connection manager process for a Net.

  Contains the all connection in a concrete Net.
  """

  use GenServer

  alias NeuronSystem.Models

  def start_link(_defaults \\ :empty) do
    GenServer.start_link(__MODULE__, [])
  end

  @doc """
  Adds a new connection to a connection manager
  """
  @spec add(pid, Models.Connection.t) :: :ok
  def add(manager_pid, %Models.Connection{} = connection_model) do
    GenServer.cast(manager_pid, {:add, connection_model})
  end

  @doc """
  Gets a list of all input connection for a whole Net
  """
  @spec get_net_in_connections(pid) :: list(Models.InConnection.t)
  def get_net_in_connections(manager_pid) do
    GenServer.call(manager_pid, {:get_net_in_out, :in})
  end

  @doc """
  Gets a list of all output connection for a whole Net
  """
  @spec get_net_out_connections(pid) :: list(Models.OutConnection.t)
  def get_net_out_connections(manager_pid) do
    GenServer.call(manager_pid, {:get_net_in_out, :out})
  end

  @doc """
  Gets a list of all input connection for a concrete neuron
  """
  @spec get_neuron_in_connections(pid, binary) :: list
  def get_neuron_in_connections(manager_pid, neuron_id) do
    GenServer.call(manager_pid, {:get_neuron_in_out, :in, neuron_id})
  end

  @doc """
  Gets a list of all output connection for a concrete neuron
  """
  @spec get_neuron_out_connections(pid, binary) :: list
  def get_neuron_out_connections(manager_pid, neuron_id) do
    GenServer.call(manager_pid, {:get_neuron_in_out, :out, neuron_id})
  end

  def handle_cast({:add, connection}, state) do
    new_state = [connection | state]
    {:noreply, new_state}
  end

  def handle_call({:get_net_in_out, :in = _type}, _from, state) do
    connections = state |> filter_by_type(Models.InConnection)
    {:reply, connections, state}
  end
  def handle_call({:get_net_in_out, :out = _type}, _from, state) do
    connections = state |> filter_by_type(Models.OutConnection)
    {:reply, connections, state}
  end

  def handle_call({:get_neuron_in_out, :in = _type, neuron_id}, _from, state) do
    connections = state |> filter_by_target_neuron(neuron_id)
    {:reply, connections, state} 
  end
  def handle_call({:get_neuron_in_out, :out = _type, neuron_id}, _from, state) do
    connections = state |> filter_by_source_neuron(neuron_id)
    {:reply, connections, state} 
  end

  defp filter_by_type(collection, module) do
    collection
    |> Enum.filter(fn(x) -> x.__struct__ == module end)
  end

  defp filter_by_target_neuron(collection, neuron_id) do
    collection
    |> Enum.filter(
      fn
        %Models.OutConnection{} = _connection -> false
        %{target_neuron: target_neuron} -> target_neuron == neuron_id
      end
    )
  end

  defp filter_by_source_neuron(collection, neuron_id) do
    collection
    |> Enum.filter(
      fn
        %Models.InConnection{} = _connection -> false
        %{source_neuron: source_neuron} -> source_neuron == neuron_id
      end
    )
  end
end
