defmodule NeuronSystem.Processes.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: NeuronSystem.Processes.Supervisor)
  end

  def init([]) do
    children = [
      worker
    ]
    opts = [strategy: :one_for_all]
    supervise(children, opts)
  end
end
