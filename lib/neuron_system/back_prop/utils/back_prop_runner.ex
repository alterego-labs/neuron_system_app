defmodule NeuronSystem.BackProp.Utils.BackPropRunner do
  @moduledoc """
  Contains logic to start Back Propagation learning algorithm.

  From very superficial sight an algorithm steps are:

  1. Detect output connection of a Net
  2. Send to each output neuron a message with a needed value inside
  3. Put a receive to wait for learning end
  """

  alias NeuronSystem.{Models, Processes}

  @doc """
  Starts back propagation learning procedure for a specific Net using a some pair from a learning set.
  """
  @spec call(NeuronSystem.Models.Net.t, map) :: :ok
  def call(%Models.Net{} = net, valid_output) do
    net
    |> send_propagation(valid_output)
    |> collect_results
  end

  defp send_propagation(net, valid_output) do
    net
    |> NeuronSystem.Net.out_connections
    |> Enum.each(&send_event_to_source_neuron(&1, net, valid_output))
    net
  end

  def send_event_to_source_neuron(connection, net, valid_output) do
    neuron_id = connection.source_neuron
    neuron_process_pid = NeuronSystem.Net.neuron_process_pid(net, neuron_id)
    needed_output = valid_output[connection.key]
    Processes.Neuron.back_prop(neuron_process_pid, {:output, net, needed_output})
  end

  defp collect_results(net) do
    net
    |> detect_input_neurons
    |> Enum.map(&collect_result_for_connection(&1))
  end

  def detect_input_neurons(net) do
    net
    |> NeuronSystem.Net.in_connections
    |> Enum.map(&(&1.target_neuron))
    |> Enum.uniq
  end

  defp collect_result_for_connection(neuron_id) do
    receive do
      {:back_prop_completed, ^neuron_id} -> neuron_id
    end
  end
end
