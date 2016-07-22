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

### Net creation

The main model is Net. When you start to build your own net the first step is to create new one:

```elixir
net = NeuronSystem.Net.create
# => %NeuronSystem.Models.Net{pid: #PID<0.198.0>}
```

### Neuron adding

The next action is to add neurons to the Net:

```elixir
{:ok, neuron} = NeuronSystem.Net.add_neuron(net, fn(value) -> 1 end)
{:ok,
 %NeuronSystem.Models.Neuron{activation_function: #Function<6.54118792/1 in :erl_eval.expr/5>,
  id: "neuron:a1d2730c-4ffc-11e6-bf11-a820663dc092"}}
```

The first parameter is the Net into which you add a new neuron. The second parameter is an
activation function.

### Connections

There are several types of connections:

1. Input connection
2. Connection between neurons
3. Output connection

Let consider each type.

#### Input connection

By adding input connection you define an input for the Net. Please, consider an example below:

```elixir
NeuronSystem.Net.add_connection(net, :in, neuron, 0.3, :x1)
```

We've added an input connection for the given `net`, which is connected to the given `neuron`. That
connection has a some weight (`0.3`) and it has a name or key. This key will be used later, when
you do activation. Income map must has an entry with the previously mentioned key. Otherwise your net
will stuck.


#### Connection between neurons

It is very easy and pretty straitforward:

```elixir
NeuronSystem.Net.add_connection(net, neuron1, neuron2, 0.2)
```

We've added a connection between `neuron1` and `neuron2` with a weight `0.2`.

#### Output connection

Output connection is used to define an output of the Net. For example:

```elixir
NeuronSystem.Net.add_connection(net, :out, neuron1, 1.0, :y1)
```

In the example above, we've specified an output connection which is named `y1`. The source for the
output is `neuron1`. And, as like as other connections, it has a weight (`1.0`).

### Activation

Once you've built your Net you can to activate it! This is the main reason to build it, right?)
After all preparation you can do it by the following code:

```elixir
income = %{x1: 1}
NeuronSystem.Net.activate!(net, income)
```

Of course, you must specify an income map. And after some time you will see a result, for example:

```elixir
# => [y1: 0]
```

Yay!

## More difficult examples

### Example of a Net with single neuron

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

### Example with two neurons in a line

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
