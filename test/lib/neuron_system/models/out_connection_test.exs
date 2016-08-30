defmodule NeuronSystem.Models.OutConnectionTest do
  use ExUnit.Case, async: true

  alias NeuronSystem.{Models}

  test "build builds new model for output connection" do
    neuron_model = %Models.Neuron{id: "source_neuron"}
    connection = Models.OutConnection.build(neuron_model, 0.5, :y)
    assert %Models.OutConnection{
      id: "connection" <> _random_uuid,
      source_neuron: "source_neuron",
      weight: 0.5,
      key: :y
    } = connection
  end
end

