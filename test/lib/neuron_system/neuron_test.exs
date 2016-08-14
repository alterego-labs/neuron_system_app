defmodule NeuronSystem.NeuronTest do
  use ExUnit.Case, async: true

  alias NeuronSystem.{Models}

  test "activate calls activation function with a given net value" do
    neuron_model = %Models.Neuron{activation_function: fn(x) -> x * 2 end}
    net_value = 3
    activation_result = NeuronSystem.Neuron.activate(neuron_model, net_value)
    assert activation_result == 6
  end
end
