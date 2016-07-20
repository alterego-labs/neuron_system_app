defmodule NeuronSystem.Utils.SendToNeuronProxy do
  alias NeuronSystem.{Models, Processes}

  def call(net, %Models.OutConnection{} = connection, value, root_pid) do
    send root_pid, {:out_result, connection.key, value}
  end
  def call(net, connection, value, root_pid) do
    
  end
end
