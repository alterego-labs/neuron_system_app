defmodule NeuronSystem.Utils.SpecHelper do
  @moduledoc """
  Provides helper function to build worker and supervisor specifications.

  Additionally, as a some sugar, provides more specific functions to build worker specification for
  the neuron process.
  """

  import Supervisor.Spec

  alias NeuronSystem.Models

  @doc """
  Builds worker specification for a neuron's process.

  ## Examples

  ```elixir
  neuron_model = %NeuronSystem.Models.Neuron{id: "neuron:123123"}
  NeuronSystem.Utils.SpecHelper.build_neuron_worker_spec(neuron_model)
  # => {:ok,
  # => {"neuron:123123",
  # =>  {NeuronSystem.Processes.Neuron, :start_link,
  # =>   [%NeuronSystem.Models.Neuron{activation_function: nil,
  # =>     id: "neuron:123123"}]}, :permanent, 5000, :worker,
  # =>  [NeuronSystem.Processes.Neuron]}}
  ```
  """
  @spec build_neuron_worker_spec(Models.Neuron.t) :: Supervisor.Spec.spec
  def build_neuron_worker_spec(%Models.Neuron{id: worker_id} = neuron_model) do
    build_worker_spec(
      NeuronSystem.Processes.Neuron,
      [neuron_model],
      worker_id
    )
  end

  @doc """
  Common helper function to build worker's process specification.

  ## Examples

  ```elixir
  neuron_model = %NeuronSystem.Models.Neuron{id: "neuron:123123"}
  NeuronSystem.Utils.SpecHelper.build_worker_spec(NeuronSystem.Models.Neuron, neuron_model, "neuron:123123")
  # => {:ok,
  # => {"neuron:123123",
  # =>  {NeuronSystem.Processes.Neuron, :start_link,
  # =>   [%NeuronSystem.Models.Neuron{activation_function: nil,
  # =>     id: "neuron:123123"}]}, :permanent, 5000, :worker,
  # =>  [NeuronSystem.Processes.Neuron]}}
  ```
  """
  @spec build_worker_spec(module, list, binary) :: Supervisor.Spec.spec
  def build_worker_spec(module, args, worker_id) do
    worker_spec = worker(module, args, [id: worker_id])
    {:ok, worker_spec}
  end

  @spec build_supervisor_spec(module, list, binary) :: Supervisor.Spec.spec
  def build_supervisor_spec(module, args, id_suffix) do
    supervisor_id = id_suffix |> gen_process_id
    supervisor_spec = supervisor(module, args, [id: supervisor_id])
    {:ok, supervisor_spec}
  end

  def gen_process_id(suffix) do
    (DateTime.utc_now |> DateTime.to_unix |> Integer.to_string) <> ":" <> suffix
  end
end
