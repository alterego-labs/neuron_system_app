defmodule NeuronSystem.BackProp.Neuron.OutputProcessor do
  @moduledoc """
  Processor of Back Propagation algorithm messages for an output neuron.

  The algorithm for the output neurons is a little bit different then for the input and hidden ones
  and contains the following steps:
  
  1. Calculate a lapse value using an needed output value and value after a forward pass.
  2. For each neuron's input connection calculate a delta value.
  3. Calculate a new weight for each ouput connection
  4. Change weights of all input connections in a Connection Manager
  5. Send messages to hidden neurons with needed calculated values: in this particular case it is `lapse`.
  """

  alias NeuronSystem.{Processes, Models}
  alias NeuronSystem.BackProp.Utils

  @doc """
  Calls processor for an output neuron.
  """
  def call(net, valid_output, {%Models.Neuron{id: neuron_id} = neuron_model, %{income_payloads: income_payloads} = options}) do
    lapse = calc_lapse(valid_output, options)
    NeuronSystem.Net.neuron_in_connections(net, neuron_id)
    |> Enum.each(fn(connection) ->
      connection_income = fetch_income_for_connection(connection, income_payloads)
      delta_w = Utils.Calculations.delta_weight(lapse, connection_income)
      new_w = Utils.Calculations.new_weight(connection.weight, delta_w)
      connection_lapse = Utils.Calculations.connection_lapse(lapse, connection.weight)
      NeuronSystem.Net.set_connection_weight(net, connection, new_w)
      send_back_prop_inside(net, connection, lapse)
    end)
  end

  defp calc_lapse(valid_output, options) do
    out_value = options |> Map.get(:out_value)
    d_out_value = options |> Map.get(:d_out_value)
    Utils.Calculations.out_lapse(out_value, d_out_value, valid_output)
  end

  defp fetch_income_for_connection(connection, income_payloads) do
    connection_source = NeuronSystem.Connection.source(connection)
    income_payloads[connection_source]
  end

  defp send_back_prop_inside(net, connection, lapse) do
    connection_source = NeuronSystem.Connection.source(connection)
    neuron_process_pid = NeuronSystem.Net.neuron_process_pid(net, connection_source)
    Processes.Neuron.back_prop(neuron_process_pid, {:hidden, net, lapse})
  end
end
