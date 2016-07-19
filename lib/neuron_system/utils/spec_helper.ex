defmodule NeuronSystem.Utils.SpecHelper do
  import Supervisor.Spec

  def build_neuron_worker_spec(%NeuronSystem.Models.Neuron{id: worker_id} = neuron_model) do
    build_worker_spec(
      NeuronSystem.Processes.Neuron,
      [neuron_model],
      worker_id
    )
  end

  def build_worker_spec(module, args, worker_id) do
    worker_spec = worker(module, args, [id: worker_id])
    {:ok, worker_spec}
  end

  def build_supervisor_spec(module, args, id_suffix) do
    supervisor_id = id_suffix |> gen_process_id
    supervisor_spec = supervisor(module, args, [id: supervisor_id])
    {:ok, supervisor_spec}
  end

  def gen_process_id(suffix) do
    (DateTime.utc_now |> DateTime.to_unix |> Integer.to_string) <> ":" <> suffix
  end
end
