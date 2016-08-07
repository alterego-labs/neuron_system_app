defmodule NeuronSystem.Net do
  @moduledoc """
  Encapsulates the all logic for the Net term in the current domain.

  The main abilities, that are provided by this module, are:

  1. Create new Net
  2. Add neuron to the Net
  3. Detect connection manager of the Net

  During a lifecycle of the Net the bunch of the processes are spawned. For example,

  ```
                               |0.100.0|  <- net's supervisor process
          _________________________|__________________________
          |                          |                       |
      |0.101.0|         |0.102.0|                  |0.103.0| 

   connection manager          neuron #1              neuron #2
     process                   process                 process
   ```
  """

  use NeuronSystem.BackProp.Net

  import NeuronSystem.Utils.SpecHelper

  alias NeuronSystem.{Models, Processes}

  @type connection_type :: :in | :out

  @type neuron_type :: :perceptron | :sigmoid

  @doc """
  Creates new Neuron Net.

  Under the hood it creates new supervisor for the net, which is supervised by the root application
  supervisor. As net supervisor the `NeuronSystem.Processes.Net` module is used.

  ## Examples

  ```elixir
  net = NeuronSystem.Net.create
  # => %NeuronSystem.Models.Net{pid: #PID<0.104.0>}
  ```
  """
  @spec create() :: Models.Net.t
  def create do
    {:ok, supervisor_spec} = build_supervisor_spec(
      Processes.Net,
      [],
      "net_process"
    )
    {:ok, pid} = Supervisor.start_child(NeuronSystem.Supervisor, supervisor_spec)
    %Models.Net{pid: pid, root_pid: self()}
  end

  @doc """
  Adds new neuron to the concrete net with the specified activation function

  ## Examples
    
  ```elixir
  net = NeuronSystem.Net.create
  neuron = NeuronSystem.Net.add_neuron(net)
  # => %NeuronSystem.Models.Neuron{activation_function: #Function<20.54118792/0 in :erl_eval.expr/5>, id: "1468929430:neuron"}
  ```
  """
  @spec add_neuron(Models.Net.t, (... -> any)) :: {:ok, Models.Neuron.t}
  def add_neuron(%Models.Net{pid: net_pid} = _net, activation_function) do
    neuron_model = Models.Neuron.build(activation_function)
    {:ok, worker_spec} = build_neuron_worker_spec(neuron_model)
    {:ok, _pid} = Supervisor.start_child(net_pid, worker_spec)
    {:ok, neuron_model}
  end

  @doc """
  Adds new predefined neuron type to the Net.

  Please, check `neuron_type` type to know all available types.

  ## Examples

  ```elixir
  {:ok, neuron_model} = NeuronSystem.Net.add_neuron(net, :perceptron, [threshold: 2])
  
  # or sigmoid neuron

  {:ok, neuron_model2} = NeuronSystem.Net.add_neuron(net, :sigmoid, [threshold: 5])
  ```
  """
  @spec add_neuron(Models.Net.t, neuron_type, [...]) :: {:ok, Models.Neuron.t}
  def add_neuron(%Models.Net{} = net, :perceptron, [threshold: threshold]) do
    add_neuron(net, fn
      x when x >= threshold -> 1
      x when x < threshold -> 0
    end)
  end
  def add_neuron(%Models.Net{} = net, :sigmoid, [threshold: threshold]) do
    add_neuron(net, fn(x)->
      1 / (1 + :math.exp(x * (-1) + threshold))
    end)
  end

  @doc """
  Creates a connection between two neurons with a given weight. Also registers just created connection
  in a connection manager.
  """
  @spec add_connection(Models.Net.t, Models.Neuron.t, Models.Neuron.t, float) :: {:ok, Models.Connection.t} | {:error, :no_connection_manager}
  def add_connection(%Models.Net{} = net, %Models.Neuron{} = source_neuron, %Models.Neuron{} = target_neuron, weight) do
    Models.Connection.build(source_neuron, target_neuron, weight)
    |> save_connection(net)
  end

  @doc """
  Creates an input or output connection.
  """
  @spec add_connection(Models.Net.t, connection_type, Models.Neuron.t, float, atom) :: {:ok, Models.InConnection.t} | {:ok, Models.OutConnection.t} | {:error, :no_connection_manager}
  def add_connection(%Models.Net{} = net, :in = _type, neuron, weight, key) do
    Models.InConnection.build(neuron, weight, key)
    |> save_connection(net)
  end
  def add_connection(%Models.Net{} = net, :out = _type, neuron, weight, key) do
    Models.OutConnection.build(neuron, weight, key)
    |> save_connection(net)
  end

  @doc """
  Returns a PID of a process for a given neuron in a given Net.
  """
  @spec neuron_process_pid(Models.Net.t, binary) :: pid
  def neuron_process_pid(%Models.Net{pid: net_pid} = _net, neuron_id) do
    detect_child_pid(net_pid, neuron_id)
  end

  @doc """
  Returns a PID of the connection manager server process.

  ## Examples
  
  ```elixir
  net = NeuronSystem.Net.create
  NeuronSystem.Net.connection_manager(net)
  # => #PID<0.107.0>
  ```
  """
  @spec connection_manager(Models.Net.t) :: pid | nil
  def connection_manager(%Models.Net{pid: net_pid}) do
    detect_child_pid(net_pid, Processes.ConnectionManager)
  end

  @doc """
  Activates a whole Net with a given income.
  """
  @spec activate!(Models.Net.t, map) :: list
  def activate!(net, income) do
    NeuronSystem.Net.Activator.call(net, income)
  end

  @doc """
  Clears a given Net.

  This operation means that an each neuron process's income payloads inbox will be cleaned up.
  """
  @spec clear(Models.Net.t) :: :ok
  def clear(%Models.Net{pid: net_pid} = _net) do
    Supervisor.which_children(net_pid)
    |> Enum.find(fn({module, pid, _type, _opts}) when is_binary(module) ->
      Processes.Neuron.clear_income_payloads(pid)
    end)
  end

  @doc """
  Detects and returns net's output connections list
  """
  @spec out_connections(Models.Net.t) :: list
  def out_connections(%Models.Net{pid: net_pid} = net) do
    NeuronSystem.Net.connection_manager(net)
    |> Processes.ConnectionManager.get_net_out_connections
  end

  @doc """
  Detects and returns net's input connections list
  """
  @spec in_connections(Models.Net.t) :: list
  def in_connections(%Models.Net{pid: net_pid} = net) do
    NeuronSystem.Net.connection_manager(net)
    |> Processes.ConnectionManager.get_net_in_connections
  end

  @doc """
  Fetches out connections for the given neuron in the Net
  """
  @spec neuron_out_connections(Models.Net.t, bitstring) :: list
  def neuron_out_connections(%Models.Net{pid: net_pid} = net, neuron_id) do
    NeuronSystem.Net.connection_manager(net)
    |> Processes.ConnectionManager.get_neuron_out_connections(neuron_id)
  end

  @doc """
  Changes a weight of a given connection and saves it in a connection manager.
  """
  @spec set_connection_weight(Models.Net.t, Models.InConnection.t | Models.OutConnection.t | Models.Connection.t, float) :: :ok
  def set_connection_weight(net, connection, new_weight) do
    net
    |> connection_manager
    |> Processes.ConnectionManager.change_weight(connection.id, new_weight)
  end

  defp detect_child_pid(net_pid, child_module) do
    worker_spec = Supervisor.which_children(net_pid)
                  |> Enum.find(fn({module, _pid, _type, _opts}) ->
                    module == child_module
                  end)
    case worker_spec do
      {_module, pid, _type, _opts} ->
        pid
      _ -> nil
    end
  end

  defp save_connection(connection_model, %Models.Net{} = net) do
    case connection_manager(net) do
      nil -> {:error, :no_connection_manager}
      manager_pid ->
        Processes.ConnectionManager.add(manager_pid, connection_model)
        {:ok, connection_model}
    end
  end
end
