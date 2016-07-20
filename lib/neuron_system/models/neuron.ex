defmodule NeuronSystem.Models.Neuron do
  @moduledoc """
  Represents a neuron in a Net.

  Contains the all information that will be needed to pass between system parts.
  """

  defstruct [:activation_function, :id]

  @type t :: %__MODULE__{}

  alias NeuronSystem.Utils.CommonHelper

  @doc """
  Builds new neuron based on a given activation function
  """
  @spec build((... -> any)) :: __MODULE__.t
  def build(activation_function) do
    id = CommonHelper.gen_process_id("neuron")
    %__MODULE__{
      activation_function: activation_function,
      id: id
    }
  end
end
