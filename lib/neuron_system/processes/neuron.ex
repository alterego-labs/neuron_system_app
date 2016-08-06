defmodule NeuronSystem.Processes.Neuron do
  @moduledoc """
  Represents neuron process.

  Will be automatically started and added to the Net's supervisor tree when you add a new one.
  """

  use GenServer
  # use NeuronSystem.BackProp.Processes.Neuron

  alias NeuronSystem.{Models, Processes, Utils}

  @spec start_link(NeuronSystem.Models.Neuron.t) :: any
  def start_link(neuron_model) do
    GenServer.start_link(__MODULE__, {neuron_model, %{}})
  end

  # Public API

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

  def handle_cast({:income_payload, source_neuron_id, value, net, root_pid}, state) do
    new_state = NeuronSystem.Utils.NeuronIncomePayloadProcessor.call({source_neuron_id, value, net, root_pid}, state)
    {:noreply, new_state}
  end

  def handle_cast(:clear_income_payloads, {neuron_model, _income_payloads}) do
    {:noreply, {neuron_model, %{}}}
  end
end
