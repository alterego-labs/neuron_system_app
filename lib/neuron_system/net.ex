defmodule NeuronSystem.Net do
  import NeuronSystem.Utils.SpecHelper

  alias NeuronSystem.{Models, Processes}

  @spec create() :: Models.Net.t
  def create do
    {:ok, supervisor_spec} = build_supervisor_spec(
      Processes.Net,
      [],
      "net_process"
    )
    {:ok, pid} = Supervisor.start_child(NeuronSystem.Supervisor, supervisor_spec)
    %Models.Net{pid: pid}
  end

  @spec add_neuron(Models.Net.t, (... -> any)) :: Models.Neuron.t
  def add_neuron(%Models.Net{pid: net_pid}, activation_function) do
    neuron_model = Models.Neuron.build(activation_function)
    {:ok, worker_spec} = build_neuron_worker_spec(neuron_model)
    {:ok, _pid} = Supervisor.start_child(net_pid, worker_spec)
    neuron_model
  end

  @spec neurons_repo(Models.Net.t) :: pid | nil
  def neurons_repo(%Models.Net{pid: net_pid}) do
    detect_child_pid(net_pid, Processes.NeuronsRepo)
  end

  @spec connection_manager(Models.Net.t) :: pid | nil
  def connection_manager(%Models.Net{pid: net_pid}) do
    detect_child_pid(net_pid, Processes.ConnectionManager)
  end

  defp detect_child_pid(net_pid, child_module) do
    worker_spec = Supervisor.which_children(net_pid)
                  |> Enum.find(fn({module, _pid, _type, _opts}) ->
                    module == child_module
                  end)
    case worker_spec do
      {_module, pid, _type, _opts} ->
        pid
      _ -> nil
    end
  end
end
