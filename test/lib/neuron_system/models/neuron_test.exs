defmodule NeuronSystem.Models.NeuronTest do
  use ExUnit.Case, async: true

  alias NeuronSystem.{Models}

  test "build build new model for neuron" do
    activation_func = fn(x) -> x * 3 end
    neuron = Models.Neuron.build(activation_func)
    assert %Models.Neuron{activation_function: _activation_func} = neuron
  end
end
