defmodule NeuronSystem.Models.Neuron do
  defstruct [:activation_function, :id]

  @type t :: %__MODULE__{}

  alias NeuronSystem.Utils.CommonHelper

  @spec build((... -> any)) :: __MODULE__.t
  def build(activation_function) do
    id = CommonHelper.gen_process_id("neuron")
    %__MODULE__{
      activation_function: activation_function,
      id: id
    }
  end
end
