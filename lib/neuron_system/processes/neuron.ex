defmodule NeuronSystem.Processes.Neuron do
  use GenServer

  @spec start_link(NeuronSystem.Models.Neuron.t) :: any
  def start_link(neuron_model) do
    GenServer.start_link(__MODULE__, neuron_model)
  end

  @spec get_model(pid) :: NeuronSystem.Models.Neuron.t
  def get_model(pid) do
    GenServer.call(pid, :get_model)
  end

  def handle_call(:get_model, _from, neuron_model) do
    {:reply, neuron_model, neuron_model}
  end

  def handle_call({:activate, args}, _from, neuron_model) do
    %{activation_function: activation_function} = neuron_model
    result = apply(activation_function, args)
    {:reply, result, neuron_model}
  end
end
