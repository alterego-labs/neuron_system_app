defmodule NeuronSystem do
  use Application

  import Supervisor.Spec

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(NeuronSystem.Processes.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: NeuronSystem.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec build_neuron((...-> any)) :: pid
  def build_neuron(activation_function) do
    neuron_model = %NeuronSystem.Models.Neuron{activation_function: activation_function}
    worker_id = (DateTime.utc_now |> DateTime.to_unix |> Integer.to_string) <> ":neuron_process"
    worker_spec = worker(NeuronSystem.Processes.Neuron, [neuron_model], [id: worker_id])
    {:ok, pid} = Supervisor.start_child(NeuronSystem.Processes.Supervisor, worker_spec)
    pid
  end

  @spec build_connection(pid, pid, float) :: NeuronSystem.Models.Connection.t
  def build_connection(source_neuron, target_neuron, weight) do
    connection_model = %NeuronSystem.Models.Connection{
      source_neuron: source_neuron,
      target_neuron: target_neuron,
      weight: wieght
    }
    connection_model
  end
end
