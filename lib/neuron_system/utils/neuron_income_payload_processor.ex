defmodule NeuronSystem.Utils.NeuronIncomePayloadProcessor do
  alias NeuronSystem.{Models, Processes, Utils}

  def call({source_neuron_id, value, net, root_pid}, {%Models.Neuron{id: neuron_id} = neuron_model, income_payloads}) do
    new_income_payloads = Map.put(income_payloads, source_neuron_id, value)
    payloads_count = new_income_payloads |> Map.keys |> Enum.count
    manager_pid = NeuronSystem.Net.connection_manager(net)
    neuron_in_connections = Processes.ConnectionManager.get_neuron_in_connections(manager_pid, neuron_id)
    if Enum.count(neuron_in_connections) == payloads_count do
      payloads_sum_value = new_income_payloads |> Map.values |> Enum.sum
      neuron_final_value = NeuronSystem.Neuron.activate(neuron_model, payloads_sum_value)
      Processes.ConnectionManager.get_neuron_out_connections(manager_pid, neuron_id)
      |> Enum.each(fn(out_connection) ->
        Utils.SendToNeuronProxy.call(net, out_connection, neuron_final_value, root_pid)
      end)
    end
    {neuron_model, new_income_payloads}
  end
end
