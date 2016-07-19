defmodule NeuronSystem.Utils.CommonHelper do
  @moduledoc """
  Provides some common helper functions.
  """

  @doc """
  Generates process ID with the given prefix.
  
  Bu default the main part of the resulting ID will be UUID value.

  ## Examples

  ```elixir
  NeuronSystem.Utils.CommonHelper.gen_process_id("neuron")
  # => "neuron:5976423a-ee35-11e3-8569-14109ff1a304"
  ```
  """
  @spec gen_process_id(binary) :: binary
  def gen_process_id(prefix) do
    prefix <> ":" <> UUID.uuid1()
  end
end
