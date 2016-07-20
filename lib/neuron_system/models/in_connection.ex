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
  def build(%Models.Neuron{id: neuron_id}, weight, key) do
    %__MODULE__{
      target_neuron: neuron_id,
      weight: weight,
      key: key
    }
  end
end
