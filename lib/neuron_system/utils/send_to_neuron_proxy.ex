defmodule NeuronSystem.Utils.SendToNeuronProxy do
  alias NeuronSystem.{Models, Processes}

  def call(_net, %Models.OutConnection{} = connection, value, root_pid) do
    send root_pid, {:out_result, connection.key, value}
  end
  def call(net, connection, value, root_pid) do
    neuron_id = connection.target_neuron
    payload_value = value * connection.weight
    neuron_process_pid = NeuronSystem.Net.neuron_process_pid(net, neuron_id)
    Processes.Neuron.income_payload(neuron_process_pid, {neuron_id, payload_value, net, root_pid})
  end
end
