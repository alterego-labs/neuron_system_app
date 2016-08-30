defmodule NeuronSystem.Utils.SendToNeuronProxyTest do
  use ExUnit.Case, async: false

  alias NeuronSystem.{Models, Processes}

  import Mock

  test "call sends message to the root if connection is output" do
    net = %Models.Net{root_pid: self()}
    connection = %Models.OutConnection{key: :y1}
    value = 10
    NeuronSystem.Utils.SendToNeuronProxy.call(net, connection, value)
    receive do
      {:out_result, :y1, out_value} -> assert value == out_value
    after
      1_000 -> assert false
    end
  end

  test "call sends income payload to a neurons in a next layer" do
    with_mocks([
      {Processes.Neuron, [], [income_payload: fn(_pid, {_source_key, _payload_value, _net}) -> :ok end]},
      {NeuronSystem.Net, [], [neuron_process_pid: fn(_net, _neuron_id) -> "pid2" end]}
      ]) do
      net = %Models.Net{root_pid: self()}
      connection = %Models.Connection{weight: 0.5, source_neuron: "source_neuron", target_neuron: "target_neuron"}
      NeuronSystem.Utils.SendToNeuronProxy.call(net, connection, 5)
      assert called Processes.Neuron.income_payload("pid2", {"source_neuron", 2.5, net})
    end
  end
end
