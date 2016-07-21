defmodule NeuronSystem.Models.Net do
  @moduledoc """
  Represents a Net - the main model in the neuron system

  Contains the only one value - the PID of the supervisor process of the Net.
  """

  defstruct [:pid]
end
