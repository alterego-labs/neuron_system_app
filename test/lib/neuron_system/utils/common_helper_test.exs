defmodule NeuronSystem.Utils.CommonHelperTest do
  use ExUnit.Case, async: true

  test "gen_process_id generates string with a given prefix and random suffix" do
    process_id = NeuronSystem.Utils.CommonHelper.gen_process_id("neuron")
    assert String.contains?(process_id, "neuron")
  end
end
