defmodule NeuronSystem.Net.Activator do
  alias NeuronSystem.{Models, Processes}

  @spec call(Models.Net.t, map, pid) :: list
  def call(net, income, root_pid) do
    net
    |> net_in_connections
    |> send_event(net, income, root_pid)

    net
    |> net_out_connections
    |> collect_results
  end

  defp net_in_connections(%Models.Net{} = net) do
    NeuronSystem.Net.connection_manager(net)
    |> Processes.ConnectionManager.get_net_in_connections
  end

  defp net_out_connections(%Models.Net{} = net) do
    NeuronSystem.Net.connection_manager(net)
    |> Processes.ConnectionManager.get_net_out_connections
  end

  defp send_event(connection, net, income, root_pid) do
    value = income[connection.key]
    NeuronSystem.Utils.SendToNeuronProxy.call(net, connection, value, root_pid)
  end

  defp collect_results(connections) do
    connections |> Enum.map(&collect_result_for_connection(&1))
  end

  defp collect_result_for_connection(connection) do
    connection_key = connection.key
    receive do
      {:out_result, connection_key, value} -> value
    end
  end
end
