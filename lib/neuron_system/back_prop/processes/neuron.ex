defmodule NeuronSystem.BackProp.Processes.Neuron do
  defmacro __using__(opts \\ :empty) do
    quote do
      @spec back_prop(pid, {:output, float} | {:hidden}) :: :ok
      def back_prop(pid, {:output, valid_output}) do
        GenServer.cast(pid, {:back_prop, :output, valid_output})
      end
      def back_prop(pid, {:hidden}) do
        GenServer.cast(pid, {:back_prop, :hidden})
      end

      def handle_cast({:back_prop, :output, valid_output}, state) do
      end

      def handle_cast({:back_prop, :hidden}, state) do
      end
    end
  end
end
