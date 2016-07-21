defmodule NeuronSystem.Processes.Net do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(NeuronSystem.Processes.ConnectionManager, [], [])
    ]
    supervise(children, strategy: :one_for_all)
  end
end
