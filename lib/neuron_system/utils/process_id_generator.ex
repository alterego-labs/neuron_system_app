defmodule NeuronSystem.Utils.ProcessIdGenerator do
  def call(suffix) do
    (DateTime.utc_now |> DateTime.to_unix |> Integer.to_string) <> ":" <> suffix
  end
end
