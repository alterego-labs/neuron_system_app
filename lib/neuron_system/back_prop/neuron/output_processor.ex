defmodule NeuronSystem.BackProp.Neuron.OutputProcessor do
  alias NeuronSystem.{Processes, Models}

  @learn_speed 0.4

  def call(net, valid_output, {%Models.Neuron{id: neuron_id} = neuron_model, options}) do
    lapse = calc_lapse(valid_output, options)
    income_payloads = options |> Map.get(:income_payloads)
    NeuronSystem.Net.neuron_out_connections(net, neuron_id)
    |> Enum.each(fn(connection) ->
      connection_source = NeuronSystem.Connection.source(connection)
      connection_income = income_payloads[connection_source]
      delta_w = @learn_speed * lapse * connection_income
      new_w = connection.weight + delta_w
      connection_lapse = lapse * connection.weight
      # TODO: Send messages to the hidden layer
    end)
  end

  defp calc_lapse(valid_output, options) do
    out_value = options |> Map.get(:out_value)
    d_out_value = options |> Map.get(:d_out_value)
    (valid_output - out_value) * d_out_value
  end
end
