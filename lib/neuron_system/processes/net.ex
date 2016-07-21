defmodule NeuronSystem.Processes.Net do
  @moduledoc """
  Supervisor process for a Net.

  Will be created automatically when you create a new Net. Also will be automatically added to
  the supervisor tree of the main program supervisor.
  """

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
