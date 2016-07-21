defmodule NeuronSystem do
  @moduledoc """
  An application for the NeuronSystem domain.

  Will start the root supervisor for the whole system.
  """

  use Application

  import Supervisor.Spec

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = []

    opts = [strategy: :one_for_one, name: NeuronSystem.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
