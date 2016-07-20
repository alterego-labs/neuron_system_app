defmodule NeuronSystem.Net do
  @moduledoc """
  Encapsulates the all logic for the Net term in the current domain.

  The main abilities, that are provided by this module, are:

  1. Create new Net
  2. Add neuron to the Net
  3. Detect neurons repo of the Net
  4. Detect connection manager of the Net

  During a lifecycle of the Net the bunch of the processes are spawned. For example,

  ```
                               |0.100.0|  <- net's supervisor process
           _______________________|____________________________________________
          |                 |                          |                       |
      |0.101.0|         |0.102.0|                  |0.103.0|              |0.104.0|

    neurons repo      connection manager          neuron #1              neuron #2
     process           process                     process                process
   ```
  """

  import NeuronSystem.Utils.SpecHelper

  alias NeuronSystem.{Models, Processes}

  @type connection_type :: :in | :out

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
    %Models.Net{pid: pid}
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
  @spec add_neuron(Models.Net.t, (... -> any)) :: {:error, :no_neurons_repo} | {:ok, Models.Neuron.t}
  def add_neuron(%Models.Net{pid: net_pid} = net, activation_function) do
    neuron_model = Models.Neuron.build(activation_function)
    {:ok, worker_spec} = build_neuron_worker_spec(neuron_model)
    {:ok, pid} = Supervisor.start_child(net_pid, worker_spec)
    case neurons_repo(net) do
      nil -> {:error, :no_neurons_repo}
      repo_pid ->
        Processes.NeuronsRepo.add(repo_pid, {neuron_model, pid})
        {:ok, neuron_model}
    end
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
  Returns a PID of the neurons repo server process.

  ## Examples
  
  ```elixir
  net = NeuronSystem.Net.create
  NeuronSystem.Net.neurons_repo(net)
  # => #PID<0.106.0>
  ```
  """
  @spec neurons_repo(Models.Net.t) :: pid | nil
  def neurons_repo(%Models.Net{pid: net_pid}) do
    detect_child_pid(net_pid, Processes.NeuronsRepo)
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
