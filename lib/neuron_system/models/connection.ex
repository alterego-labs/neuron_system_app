defmodule NeuronSystem.Models.Connection do
  @moduledoc """
  Represents a connection between neurons in a Net.

  Also this module provides a struct which contains the all information about connected neurons and
  its weight.
  """

  defstruct [:id, :source_neuron, :target_neuron, :weight]

  alias NeuronSystem.Models
  alias NeuronSystem.Utils.CommonHelper

  @type t :: %__MODULE__{}

  @doc """
  Builds a new connection between given neurons and with a concrete weight.
  """
  @spec build(Models.Neuron.t, Models.Neuron.t, float) :: Models.Connection.t
  def build(%Models.Neuron{id: source_id}, %Models.Neuron{id: target_id}, weight) do
    %__MODULE__{
      id: CommonHelper.gen_process_id("connection"),
      source_neuron: source_id,
      target_neuron: target_id,
      weight: weight
    } 
  end
end
