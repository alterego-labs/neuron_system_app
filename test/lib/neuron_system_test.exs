defmodule NeuronSystemTest do
  use ExUnit.Case

  test "forward way of a simple Net with 3 layers" do
    income = %{x1: 1.0, x2: 0.0}

    # Create network
    net = NeuronSystem.Net.create

    # Create needed neurons 
    {:ok, neuronA1} = NeuronSystem.Net.add_neuron(net, :sigmoid, [threshold: 0.0])
    {:ok, neuronA2} = NeuronSystem.Net.add_neuron(net, :sigmoid, [threshold: 0.0])
    {:ok, neuronA3} = NeuronSystem.Net.add_neuron(net, :sigmoid, [threshold: 0.0])
    {:ok, neuronB1} = NeuronSystem.Net.add_neuron(net, :sigmoid, [threshold: 0.0])
    {:ok, neuronB2} = NeuronSystem.Net.add_neuron(net, :sigmoid, [threshold: 0.0])
    {:ok, neuronC1} = NeuronSystem.Net.add_neuron(net, :sigmoid, [threshold: 0.0])

    # Add in connection
    NeuronSystem.Net.add_connection(net, :in, neuronA1, 0.19592, :x1)
    NeuronSystem.Net.add_connection(net, :in, neuronA2, 0.32244, :x1)
    NeuronSystem.Net.add_connection(net, :in, neuronA3, 0.16243, :x1)
    NeuronSystem.Net.add_connection(net, :in, neuronA1, 0.6, :x2)
    NeuronSystem.Net.add_connection(net, :in, neuronA2, -0.5, :x2)
    NeuronSystem.Net.add_connection(net, :in, neuronA3, 0.4, :x2)

    # Add out connection
    NeuronSystem.Net.add_connection(net, :out, neuronC1, 1.0, :y)

    # Add connection in hidden layers
    NeuronSystem.Net.add_connection(net, neuronA1, neuronB1, -0.0855)
    NeuronSystem.Net.add_connection(net, neuronA1, neuronB2, -0.398)
    NeuronSystem.Net.add_connection(net, neuronA2, neuronB1, 0.715)
    NeuronSystem.Net.add_connection(net, neuronA2, neuronB2, 1.10207)
    NeuronSystem.Net.add_connection(net, neuronA3, neuronB1, 0.374)
    NeuronSystem.Net.add_connection(net, neuronA3, neuronB2, 0.79194)
    NeuronSystem.Net.add_connection(net, neuronB1, neuronC1, 0.831)
    NeuronSystem.Net.add_connection(net, neuronB2, neuronC1, 0.133)

    # Activate it!
    results = NeuronSystem.Net.activate!(net, income)
    
    assert [y: 0.6511113215704272] = results
  end
end
