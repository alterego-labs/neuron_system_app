defmodule NeuronSystem.Models.InConnectionTest do
  use ExUnit.Case, async: true

  alias NeuronSystem.{Models}

  test "build builds new model for input connection" do
    neuron_model = %Models.Neuron{id: "target_neuron"}
    connection = Models.InConnection.build(neuron_model, 0.5, :x1)
    assert %Models.InConnection{
      id: "connection" <> _random_uuid,
      target_neuron: "target_neuron",
      weight: 0.5,
      key: :x1
    } = connection
  end
end
