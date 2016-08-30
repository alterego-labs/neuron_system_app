defmodule NeuronSystem.Models.ConnectionTest do
  use ExUnit.Case, async: true

  alias NeuronSystem.{Models}

  test "build builds new connection model" do
    source_neuron = %Models.Neuron{id: "source_neuron"}
    target_neuron = %Models.Neuron{id: "target_neuron"}
    connection = Models.Connection.build(source_neuron, target_neuron, 0.5)
    assert %Models.Connection{
      id: "connection" <> _random_uuid,
      source_neuron: "source_neuron",
      target_neuron: "target_neuron",
      weight: 0.5
    } = connection
  end
end
