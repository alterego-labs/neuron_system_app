defmodule NeuronSystem.Processes.Neuron do
  @moduledoc """
  Represents neuron process.

  Will be automatically started and added to the Net's supervisor tree when you add a new one.
  """

  use GenServer

  alias NeuronSystem.{Models, Processes, Utils}

  @spec start_link(NeuronSystem.Models.Neuron.t) :: any
  def start_link(neuron_model) do
    GenServer.start_link(__MODULE__, {neuron_model, %{}})
  end

  # Public API

  @doc """
  Fetches a neuron model struct from a concrete neuron process.
  """
  @spec get_model(pid) :: NeuronSystem.Models.Neuron.t
  def get_model(pid) do
    GenServer.call(pid, :get_model)
  end

  @doc """
  Sets a new activation function for a given neuron process
  """
  @spec set_activation_function(pid, (... -> any)) :: :ok
  def set_activation_function(pid, activation_function) do
    GenServer.cast(pid, {:set_activation_function, activation_function}
  end

  @doc """
  Clears an income payloads inbox.

  Is very useful when you in a runtime change parameters of a some neurons and want to activate
  a Net again.
  """
  @spec clear_income_payloads(pid) :: :ok
  def clear_income_payloads(pid) do
    GenServer.cast(pid, :clear_income_payloads)
  end

  @doc """
  Casts income payload event.

  This event means that some neuron from the previous layer was activated and sent its value to
  a next layer.
  """
  @spec income_payload(pid, {binary, float, Models.Net.t, pid}) :: :ok
  def income_payload(pid, {source_neuron_id, value, net, root_pid}) do
    GenServer.cast(pid, {:income_payload, source_neuron_id, value, net, root_pid})
  end

  # Callbacks

  def handle_call(:get_model, _from, {neuron_model, _income_payloads} = state) do
    {:reply, neuron_model, state}
  end

  def handle_call({:activate, args}, _from, {neuron_model, _income_payloads} = state) do
    %{activation_function: activation_function} = neuron_model
    result = apply(activation_function, args)
    {:reply, result, state}
  end

  def handle_cast({:income_payload, source_neuron_id, value, net, root_pid}, {%Models.Neuron{id: neuron_id, activation_function: activation_function} = neuron_model, income_payloads} = _state) do
    new_income_payloads = Map.put(income_payloads, source_neuron_id, value)
    payloads_count = Map.keys(new_income_payloads) |> Enum.count
    manager_pid = NeuronSystem.Net.connection_manager(net)
    neuron_in_connections = Processes.ConnectionManager.get_neuron_in_connections(manager_pid, neuron_id)
    if Enum.count(neuron_in_connections) == payloads_count do
      payloads_sum_value = Map.values(new_income_payloads) |> Enum.sum
      neuron_final_value = activation_function.(payloads_sum_value)
      Processes.ConnectionManager.get_neuron_out_connections(manager_pid, neuron_id)
      |> Enum.each(fn(out_connection) ->
        Utils.SendToNeuronProxy.call(net, out_connection, neuron_final_value, root_pid)
      end)
    end
    new_state = {neuron_model, new_income_payloads}
    {:noreply, new_state}
  end

  def handle_cast({:set_activation_function, activation_function}, {neuron_model, income_payloads}) do
    new_neuron_model = Map.put(neuron_model, activation_function: activation_function)
    {:noreply, {new_neuron_model, income_payloads}}
  end

  def handle_cast(:clear_income_payloads, {neuron_model, _income_payloads}) do
    {:noreply, {neuron_model, %{}}}
  end
end
