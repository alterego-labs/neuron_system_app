defmodule NeuronSystem.NetTest do
  use ExUnit.Case

  alias NeuronSystem.{Models}

  test "create adds new supervisor for a Net" do
    net_model = NeuronSystem.Net.create
    assert %Models.Net{} = net_model
    process_info = Process.info(net_model.pid)
    assert process_info != nil
  end

  test "create saves info to the struct and returns it" do
    %Models.Net{pid: net_pid, root_pid: root_pid} = NeuronSystem.Net.create
    assert net_pid != nil
    assert root_pid == self()
  end

  test "create adds default list of childrens for a Net" do
    net_model = NeuronSystem.Net.create
    childrens = Supervisor.which_children(net_model.pid)
    assert Enum.count(childrens) == 1
  end

  test "add_neuron adds new neuron with a custom activation function" do
    %Models.Net{pid: net_pid} = net = NeuronSystem.Net.create
    childrens = Supervisor.which_children(net_pid)
    assert Enum.count(childrens) == 1
    {:ok, %Models.Neuron{}} = NeuronSystem.Net.add_neuron(net, fn(x) -> x end)
    childrens = Supervisor.which_children(net_pid)
    assert Enum.count(childrens) == 2
  end

  test "add_neuron adds perceptron neuron" do
    %Models.Net{pid: net_pid} = net = NeuronSystem.Net.create
    childrens = Supervisor.which_children(net_pid)
    assert Enum.count(childrens) == 1
    {:ok, %Models.Neuron{}} = NeuronSystem.Net.add_neuron(net, :perceptron, [threshold: 0.5])
    childrens = Supervisor.which_children(net_pid)
    assert Enum.count(childrens) == 2
  end

  test "add_neuron adds sigmoid neuron" do
    %Models.Net{pid: net_pid} = net = NeuronSystem.Net.create
    childrens = Supervisor.which_children(net_pid)
    assert Enum.count(childrens) == 1
    {:ok, %Models.Neuron{}} = NeuronSystem.Net.add_neuron(net, :sigmoid, [threshold: 0.5])
    childrens = Supervisor.which_children(net_pid)
    assert Enum.count(childrens) == 2
  end

  test "neuron_process_pid returns PID of a neuron's process if such one exists" do
    net = NeuronSystem.Net.create
    {:ok, %Models.Neuron{id: neuron_id}} = NeuronSystem.Net.add_neuron(net, :sigmoid, [threshold: 0.5])
    neuron_pid = NeuronSystem.Net.neuron_process_pid(net, neuron_id)
    assert neuron_pid != nil
  end

  test "neuron_process_pid returns nil if such one does not exist" do
    net = NeuronSystem.Net.create
    neuron_pid = NeuronSystem.Net.neuron_process_pid(net, "neuron:ahahahaa")
    assert neuron_pid == nil
  end

  test "connection_manager returns PID of a connection manager of a Net" do
    net = NeuronSystem.Net.create
    connection_manager_pid = NeuronSystem.Net.connection_manager(net)
    assert connection_manager_pid != nil
  end

  test "add_connection adds link between neurons" do
    net = NeuronSystem.Net.create
    source_neuron_model = %Models.Neuron{}
    target_neuron_model = %Models.Neuron{}
    connections = NeuronSystem.Net.get_all_connections(net)
    assert Enum.count(connections) == 0
    NeuronSystem.Net.add_connection(net, source_neuron_model, target_neuron_model, 0.3)
    connections = NeuronSystem.Net.get_all_connections(net)
    assert Enum.count(connections) == 1
  end

  test "add_connection adds income connection of a Net" do
    net = NeuronSystem.Net.create
    target_neuron_model = %Models.Neuron{}
    connections = NeuronSystem.Net.get_all_connections(net)
    assert Enum.count(connections) == 0
    NeuronSystem.Net.add_connection(net, :in, target_neuron_model, 0.3, :x1)
    connections = NeuronSystem.Net.get_all_connections(net)
    assert Enum.count(connections) == 1
  end

  test "add_connection adds output connection of a Net" do
    net = NeuronSystem.Net.create
    target_neuron_model = %Models.Neuron{}
    connections = NeuronSystem.Net.get_all_connections(net)
    assert Enum.count(connections) == 0
    NeuronSystem.Net.add_connection(net, :out, target_neuron_model, 0.3, :y1)
    connections = NeuronSystem.Net.get_all_connections(net)
    assert Enum.count(connections) == 1
  end

  test "in_connections returns input connections for a Net" do
    net = NeuronSystem.Net.create
    target_neuron_model = %Models.Neuron{}
    connections = NeuronSystem.Net.in_connections(net)
    assert Enum.count(connections) == 0
    NeuronSystem.Net.add_connection(net, :in, target_neuron_model, 0.3, :x1)
    connections = NeuronSystem.Net.in_connections(net)
    assert Enum.count(connections) == 1
  end

  test "out_connection returns output connections of a Net" do
    net = NeuronSystem.Net.create
    target_neuron_model = %Models.Neuron{}
    connections = NeuronSystem.Net.out_connections(net)
    assert Enum.count(connections) == 0
    NeuronSystem.Net.add_connection(net, :out, target_neuron_model, 0.3, :y1)
    connections = NeuronSystem.Net.out_connections(net)
    assert Enum.count(connections) == 1
  end

  test "get_all_connections returns the list of all connections in a Net" do
    net = NeuronSystem.Net.create
    source_neuron_model = %Models.Neuron{}
    target_neuron_model = %Models.Neuron{}
    connections = NeuronSystem.Net.get_all_connections(net)
    assert Enum.count(connections) == 0
    NeuronSystem.Net.add_connection(net, source_neuron_model, target_neuron_model, 0.3)
    NeuronSystem.Net.add_connection(net, :in, target_neuron_model, 0.3, :x1)
    NeuronSystem.Net.add_connection(net, :out, source_neuron_model, 0.3, :y1)
    connections = NeuronSystem.Net.get_all_connections(net)
    assert Enum.count(connections) == 3
  end

  test "neuron_out_connections returns a list of out connection of a neuron" do
    net = NeuronSystem.Net.create
    source_neuron_model = %Models.Neuron{id: "source_neuron"}
    target_neuron_model = %Models.Neuron{id: "target_neuron"}
    NeuronSystem.Net.add_connection(net, source_neuron_model, target_neuron_model, 0.3)
    connections = NeuronSystem.Net.neuron_out_connections(net, source_neuron_model.id)
    assert Enum.count(connections) == 1
  end

  test "neuron_in_connections returns a list of out connection of a neuron" do
    net = NeuronSystem.Net.create
    source_neuron_model = %Models.Neuron{id: "source_neuron"}
    target_neuron_model = %Models.Neuron{id: "target_neuron"}
    NeuronSystem.Net.add_connection(net, source_neuron_model, target_neuron_model, 0.3)
    connections = NeuronSystem.Net.neuron_in_connections(net, target_neuron_model.id)
    assert Enum.count(connections) == 1
  end
end
