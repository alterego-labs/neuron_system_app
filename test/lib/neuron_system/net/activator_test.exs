defmodule NeuronSystem.Net.ActivatorTest do
  use ExUnit.Case, async: true

  import Mock

  test "call sends events to neurons and waits for responses" do
    net = NeuronSystem.Net.create
    {:ok, neuronA} = NeuronSystem.Net.add_neuron(net, :perceptron, [threshold: 0.5])
    {:ok, inConnection} = NeuronSystem.Net.add_connection(net, :in, neuronA, 0.5, :x1)
    NeuronSystem.Net.add_connection(net, :out, neuronA, 0.5, :y1)


    with_mock NeuronSystem.Utils.SendToNeuronProxy, [call: fn(_net, _connection, _value) -> :ok end] do
      send self(), {:out_result, :y1, 2.3}

      results = NeuronSystem.Net.Activator.call(net, %{x1: 2.0})

      assert [y1: 2.3] = results

      assert called NeuronSystem.Utils.SendToNeuronProxy.call(net, inConnection, 2.0)
    end
  end
end
