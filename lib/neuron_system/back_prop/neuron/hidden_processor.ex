defmodule NeuronSystem.BackProp.Neuron.HiddenProcessor do
  alias NeuronSystem.{Models, Processes}
  alias NeuronSystem.BackProp.Utils

  def call(net, from_neuron_id, lapse, {%Models.Neuron{id: neuron_id} = neuron_model, options}) do
    new_options = options |> push_new_income_lapse(from_neuron_id, lapse)
    neuron_out_connections = NeuronSystem.Net.neuron_out_connections(net, neuron_id) 
    if received_all?(new_options, neuron_out_connections) do
      lapse = calc_overall_lapse(new_options)
      neuron_in_connections = NeuronSystem.Net.neuron_in_connections(net, neuron_id)
      neuron_in_connections |> Enum.each(fn(connection) ->
        connection_income = fetch_income_for_connection(connection, income_payloads)
        delta_w = Utils.Calculations.delta_weight(lapse, connection_income)
        new_w = Utils.Calculations.new_weight(connection.weight, delta_w)
        connection_lapse = Utils.Calculations.connection_lapse(lapse, connection.weight)
        NeuronSystem.Net.set_connection_weight(net, connection, new_w)
        if %Models.Connection{} = connection do
          send_back_prop_inside(net, neuron_id, connection, connection_lapse)
        end
      end)
      if at_least_one_is_in_connection?(neuron_in_connections) do
        send_back_prop_completed(net, neuron_id)
      end
    end
    {neuron_model, new_options}
  end

  @spec push_new_income_lapse(map, bitstring, float) :: map
  defp push_new_income_lapse(options, from_neuron_id, lapse) do
    income_lapse = options |> Map.get(:income_lapse, %{})
    new_income_lapse = income_lapse |> Map.put(from_neuron_id, lapse)
    Map.put(options, :income_lapse, new_income_lapse)
  end

  defp received_all?(%{income_lapse: income_lapse} = _options, out_connections) do
    income_count = income_lapse |> Map.keys |> Enum.count
    connections_count = out_connections |> Enum.count
    income_count == connections_count
  end

  defp calc_overall_lapse(%{income_lapse: income_lapse} = _options) do
    income_lapse |> Map.values |> Enum.sum
  end

  defp send_back_prop_inside(net, neuron_id, connection, connection_lapse) do
    connection_source = NeuronSystem.Connection.source(connection)
    neuron_process_pid = NeuronSystem.Net.neuron_process_pid(net, connection_source)
    Processes.Neuron.back_prop(neuron_process_pid, {:hidden, net, neuron_id, lapse})
  end

  defp at_least_one_is_in_connection?(connections) do
    Enum.any?(neuron_in_connections, fn
      (%Models.InConnection{} = conn) -> true
      _ -> false
    end)
  end

  defp send_back_prop_completed(%Models.Net{root_pid: root_pid} = _net, neuron_id) do
    send root_pid, {:back_prop_completed, neuron_id}
  end
end
