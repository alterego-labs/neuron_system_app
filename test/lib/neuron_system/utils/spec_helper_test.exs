defmodule NeuronSystem.Utils.SpecHelperTest do
  use ExUnit.Case, async: true

  alias NeuronSystem.{Models}

  defmodule TestProcess do
  end

  test "build_supervisor_spec builds specification for a supervisor process" do
    spec = NeuronSystem.Utils.SpecHelper.build_supervisor_spec(TestProcess, [], "test_process") 
    assert {:ok,
      {"test_process:" <> _random_uuid, {
          NeuronSystem.Utils.SpecHelperTest.TestProcess,
          :start_link, []
        },
        :permanent,
        :infinity,
        :supervisor,
        [NeuronSystem.Utils.SpecHelperTest.TestProcess]
      }
    } = spec
  end

  test "build_worker_spec builds specification for a worker process" do
    worker_id = "test_process:a1212"
    spec = NeuronSystem.Utils.SpecHelper.build_worker_spec(TestProcess, [], worker_id)
    assert {
      :ok,
      {"test_process:a1212", {
          NeuronSystem.Utils.SpecHelperTest.TestProcess,
          :start_link,
          []
        },
        :permanent,
        5000,
        :worker,
        [NeuronSystem.Utils.SpecHelperTest.TestProcess]
      }
    } = spec
  end

  test "build_neuron_worker_spec builds specification for a neuron process" do
    neuron_model = %Models.Neuron{id: "neuron:1234"}
    spec = NeuronSystem.Utils.SpecHelper.build_neuron_worker_spec(neuron_model)
    assert {
      :ok, {
        "neuron:1234", {
          NeuronSystem.Processes.Neuron,
          :start_link,
          [%NeuronSystem.Models.Neuron{activation_function: nil, id: "neuron:1234"}]
        },
        :permanent,
        5000,
        :worker,
        [NeuronSystem.Processes.Neuron]
      }
    } = spec
  end
end
