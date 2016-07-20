defmodule NeuronSystem.Models.InConnection do
  @moduledoc """
  Represents an input connection for a Net.
  """

  defstruct [:target_neuron, :weight, :key]

  alias NeuronSystem.Models

  @type t :: %__MODULE__{}

  @doc """
  Builds a new input connection
  """
  @spec build(Models.Neuron.t, float, atom) :: __MODULE__.t
  def build(neuron, weight, key) do
    %__MODULE__{
      target_neuron: neuron,
      weight: weight,
      key: key
    }
  end
end
