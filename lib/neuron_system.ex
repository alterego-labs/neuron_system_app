defmodule NeuronSystem do
  use Application

  import Supervisor.Spec

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: NeuronSystem.Worker.start_link(arg1, arg2, arg3)
      # worker(NeuronSystem.Worker, [arg1, arg2, arg3]),
      supervisor(NeuronSystem.Processes.Supervisor, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
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
end
