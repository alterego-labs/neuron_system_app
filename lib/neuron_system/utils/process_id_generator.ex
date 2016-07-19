defmodule NeuronSystem.Utils.ProcessIdGenerator do
  def call(suffix) do
    suffix <> ":" <> UUID.uuid1()
  end
end
