defmodule NeuronSystem.Neuron do
  @moduledoc """
  Contains the common functions for a neuron.
  """

  alias NeuronSystem.Models

  @type net_value :: float

  @doc """
  Activates a given neuron using a passed NET value.
  """
  @spec activate(Models.Neuron.t, net_value) :: float
  def activate(%Models.Neuron{activation_function: activation_function}, net_value) do
    activation_function.(net_value)
  end
end
