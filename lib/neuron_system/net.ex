defmodule NeuronSystem.Net do
  import NeuronSystem.Utils.SpecHelper

  @spec create :: NeuronSystem.Models.Net.t
  def create do
    {:ok, supervisor_spec} = build_supervisor_spec(
      NeuronSystem.Processes.Net,
      [],
      "net_process"
    )
    {:ok, pid} = Supervisor.start_child(NeuronSystem.Supervisor, supervisor_spec)
    %NeuronSystem.Models.Net{pid: pid}
  end

  @spec add_neuron(NeuronSystem.Models.Net.t, (... -> any)) :: pid
  def add_neuron(%NeuronSystem.Models.Net{pid: net_pid}, activation_function) do
    neuron_model = %NeuronSystem.Models.Neuron{activation_function: activation_function}
    {:ok, worker_spec} = build_worker_spec(
      NeuronSystem.Processes.Neuron,
      [neuron_model],
      "neuron_process"
    )
    {:ok, pid} = Supervisor.start_child(net_pid, worker_spec)
    pid
  end
end
