defmodule NeuronSystem do
  use Application

  import Supervisor.Spec

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = []

    opts = [strategy: :one_for_one, name: NeuronSystem.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec build_connection(pid, pid, float) :: NeuronSystem.Models.Connection.t
  def build_connection(source_neuron, target_neuron, weight) do
    connection_model = %NeuronSystem.Models.Connection{
      source_neuron: source_neuron,
      target_neuron: target_neuron,
      weight: weight
    }
    connection_model
  end
end
