defmodule NeuronSystem.Utils.NeuronIncomePayloadProcessor do
  @moduledoc """
  Encapsulates the whole functional for processing income payload to a neuron.
  """

  alias NeuronSystem.{Models, Processes, Utils}

  @type neuron_process_state :: {Models.Neuron.t, map}

  @doc """
  Calls income payload processor
  """
  @spec call(atom | bitstring, float, Models.Net.t, neuron_process_state) :: neuron_process_state
  def call(source_neuron_id, value, net, {%Models.Neuron{id: neuron_id} = neuron_model, %{income_payloads: income_payloads} = options}) do
    neuron_connections = get_neuron_connections(net, neuron_id)
    new_income_payloads = income_payloads |> Map.put(source_neuron_id, value)
    payloads_count = new_income_payloads |> Map.keys |> Enum.count
    in_connections_count = neuron_connections[:in] |> Enum.count
    if in_connections_count == payloads_count do
      send_out_messages(net, neuron_model, new_income_payloads, neuron_connections[:out])
    end
    new_options = options |> Map.put(:income_payloads, new_income_payloads)
    {neuron_model, new_options}
  end

  defp get_neuron_connections(net, neuron_id) do
    manager_pid = NeuronSystem.Net.connection_manager(net)
    neuron_in_connections = Processes.ConnectionManager.get_neuron_in_connections(manager_pid, neuron_id)
    neuron_out_connections = Processes.ConnectionManager.get_neuron_out_connections(manager_pid, neuron_id)
    %{in: neuron_in_connections, out: neuron_out_connections}
  end

  defp send_out_messages(net, neuron_model, income_payloads, out_connections) do
    payloads_sum_value = income_payloads |> Map.values |> Enum.sum
    neuron_final_value = NeuronSystem.Neuron.activate(neuron_model, payloads_sum_value)
    out_connections |> Enum.each(fn(out_connection) ->
      Utils.SendToNeuronProxy.call(net, out_connection, neuron_final_value)
    end)
  end
end
