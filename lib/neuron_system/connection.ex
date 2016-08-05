defmodule NeuronSystem.Connection do
  @moduledoc """
  Contains the common function for the all types of connections.
  """

  alias NeuronSystem.Models.{Connection, InConnection, OutConnection}

  @doc """
  Retrieves a source of the connection.

  For InConnection it is a key which represents an input value.
  For the other types the source is a source neuron's ID.
  """
  @spec source(InConnection.t | Connection.t | OutConnection.t) :: atom | bitstring
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
