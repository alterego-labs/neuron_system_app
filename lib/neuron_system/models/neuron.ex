defmodule NeuronSystem.Models.Neuron do
  defstruct [:activation_function, :id]

  alias NeuronSystem.Utils.ProcessIdGenerator

  # @spec build((... -> any)) :: __MODULE__.t
  def build(activation_function) do
    id = ProcessIdGenerator.call("neuron")
    %__MODULE__{
      activation_function: activation_function,
      id: id
    }
  end
end
