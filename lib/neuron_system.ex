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

  def start_testing(x1 \\ 1) do
    income = %{x1: x1}
    net = NeuronSystem.Net.create
    {:ok, neuron1} = NeuronSystem.Net.add_neuron(net, fn
      x when x >= 0.5 -> 1
      x when x < 0.5 -> 0
    end)
    {:ok, neuron2} = NeuronSystem.Net.add_neuron(net, fn
      x when x >= 0.2 -> 1
      x when x < 0.2 -> 0
    end)
    NeuronSystem.Net.add_connection(net, :in, neuron1, 0.3, :x1)
    NeuronSystem.Net.add_connection(net, neuron1, neuron2, 0.2)
    NeuronSystem.Net.add_connection(net, :out, neuron2, 1.0, :y1)
    NeuronSystem.Net.activate!(net, income)
  end
end
