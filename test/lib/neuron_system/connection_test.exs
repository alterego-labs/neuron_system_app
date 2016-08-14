defmodule NeuronSystem.ConnectionTest do
  use ExUnit.Case, async: true

  alias NeuronSystem.{Models}

  test "source when connection is input" do
    connection = %Models.InConnection{key: :x1}
    source_value = NeuronSystem.Connection.source(connection)
    assert source_value == :x1
  end

  test "source when connection is between neurons" do
    source_neuron = "neuron:sadsdasdas"
    connection = %Models.Connection{source_neuron: source_neuron}
    source_value = NeuronSystem.Connection.source(connection)
    assert source_value == source_neuron
  end

  test "source when connection is output" do
    source_neuron = "neuron:sadsdasdas"
    connection = %Models.OutConnection{source_neuron: source_neuron}
    source_value = NeuronSystem.Connection.source(connection)
    assert source_value == source_neuron
  end
end
