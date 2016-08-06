defmodule NeuronSystem.BackProp.Net do
  @moduledoc """
  Represents an extension of the Net to support back propagation learning algorithm.
  """

  defmacro __using__(_opts \\ :empty) do
    quote do
      @spec back_prop!(NeuronSystem.Models.Net.t, map) :: :ok
      def back_prop!(net, valid_output) do
        NeuronSystem.BackProp.Utils.BackPropRunner.call(net, valid_output)       
      end
    end
  end
end
