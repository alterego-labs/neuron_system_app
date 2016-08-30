defmodule NeuronSystem.BackProp.Net do
  @moduledoc """
  Represents an extension of the Net to support back propagation learning algorithm.

  ## Usage

  Use this module in the origin Net module:

  ```elixir
  defmodule NeuronSystem.Net do
    ...
    use NeuronSystem.BackProp.Net
    ...
  end
  ```

  After that you can learn your net by calling:
  ```elixir
  net = ... # Net creation flow
  # Add neurons, connections...
  NeuronSystem.Net.back_prop!(net, %{y: 1})
  ```
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
