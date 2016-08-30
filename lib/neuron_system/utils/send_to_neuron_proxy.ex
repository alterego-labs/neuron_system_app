defmodule NeuronSystem.Utils.SendToNeuronProxy do
  @moduledoc """
  Encapsulates logic of a sending event from one neuron to another.
  """

  alias NeuronSystem.{Models, Processes}

  @doc """
  Calls sending event processing
  """
  @spec call(Models.Net.t, Models.InConnection.t | Models.OutConnection.t | Models.Connection.t, float) :: any
  def call(%Models.Net{root_pid: root_pid} = _net, %Models.OutConnection{} = connection, value) do
    send root_pid, {:out_result, connection.key, value}
  end
  def call(%Models.Net{root_pid: root_pid} = net, connection, value) do
    neuron_source_key = NeuronSystem.Connection.source(connection)
    neuron_id = connection.target_neuron
    payload_value = value * connection.weight
    neuron_process_pid = NeuronSystem.Net.neuron_process_pid(net, neuron_id)
    Processes.Neuron.income_payload(neuron_process_pid, {neuron_source_key, payload_value, net})
  end
end
