defmodule NeuronSystem.BackProp.Processes.Neuron do
  defmacro __using__(opts \\ :empty) do
    quote do
      @spec back_prop(pid, {:output, float} | {:hidden}) :: :ok
      def back_prop(pid, {:output, net, valid_output}) do
        GenServer.cast(pid, {:back_prop, :output, net, valid_output})
      end
      def back_prop(pid, {:hidden}) do
        GenServer.cast(pid, {:back_prop, :hidden})
      end

      def handle_cast({:back_prop, :output, net, valid_output}, {_neuron_model, _options} = state) do
        NeuronSystem.BackProp.Neuron.OutputProcessor.call(net, valid_output, state)
        {:noreply, state}
      end

      def handle_cast({:back_prop, :hidden}, state) do
      end
    end
  end
end
