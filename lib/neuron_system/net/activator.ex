defmodule NeuronSystem.Net.Activator do
  @moduledoc """
  Net activator.

  Encapsulates all logic which will be performed to start a Net:

  1. Sends all income events to the appropriate neurons
  2. Puts a bunch of `receive` blocks to collect outputs
  """

  alias NeuronSystem.{Models, Processes}

  @doc """
  The main point for an activator.
  """
  @spec call(Models.Net.t, map) :: list
  def call(%Models.Net{} = net, income) do
    net |> send_in_events(income)
    net |> collect_net_results
  end

  defp send_in_events(net, income) do
    net
    |> net_in_connections
    |> Enum.each(&send_event(&1, net, income))
  end

  defp net_in_connections(%Models.Net{} = net) do
    NeuronSystem.Net.connection_manager(net)
    |> Processes.ConnectionManager.get_net_in_connections
  end

  defp send_event(connection, net, income) do
    value = income[connection.key]
    NeuronSystem.Utils.SendToNeuronProxy.call(net, connection, value)
  end

  defp collect_net_results(net) do
    net
    |> net_out_connections
    |> collect_results
  end

  defp net_out_connections(%Models.Net{} = net) do
    NeuronSystem.Net.connection_manager(net)
    |> Processes.ConnectionManager.get_net_out_connections
  end

  defp collect_results(connections) do
    connections |> Enum.map(&collect_result_for_connection(&1))
  end

  defp collect_result_for_connection(connection) do
    connection_key = connection.key
    receive do
      {:out_result, connection_key, value} -> {connection.key, value}
    end
  end
end
