defmodule NeuronSystem.Models.OutConnection do
  @moduledoc """
  Represents an output connection for a Net.
  """

  defstruct [:source_neuron, :weight, :key]

  alias NeuronSystem.Models

  @type t :: %__MODULE__{}

  @doc """
  Builds a new output connection
  """
  @spec build(Models.Neuron.t, float, atom) :: __MODULE__.t
  def build(neuron, weight, key) do
    %__MODULE__{
      source_neuron: neuron,
      weight: weight,
      key: key
    }
  end
end
