defmodule NeuronSystem.Connection do
  alias NeuronSystem.Models.{Connection, InConnection, OutConnection}

  def source(%InConnection{key: key}) do
    key
  end
  def source(%Connection{source_neuron: source_neuron}) do
    source_neuron
  end
  def source(%OutConnection{source_neuron: source_neuron}) do
    source_neuron
  end
end
