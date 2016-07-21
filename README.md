# NeuronSystem

The very simple example of the implementation of the neuron network on Elixir.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `neuron_system` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:neuron_system, "~> 0.1.0"}]
    end
    ```

  2. Ensure `neuron_system` is started before your application:

    ```elixir
    def application do
      [applications: [:neuron_system]]
    end
    ```

## Usage

### Very basic example of a Net with single neuron

```elixir
income = %{x1: 0.5}
net = NeuronSystem.Net.create
{:ok, neuron1} = NeuronSystem.Net.add_neuron(net, fn
  x when x >= 1 -> 1
  x when x < 1 -> 0
end)
NeuronSystem.Net.add_connection(net, :in, neuron1, 1.0, :x1)
NeuronSystem.Net.add_connection(net, :out, neuron1, 1.0, :y1)
NeuronSystem.Net.activate!(net, income)
# => [y1: 0]
```

### Basic example with two neurons in a line

```elixir
income = %{x1: 3}
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
# => [y1: 1]
```


## Further ideas

1. The main next goal - implement learning algorithm
2. Add ability to create different types of the neurons using the high-level API
