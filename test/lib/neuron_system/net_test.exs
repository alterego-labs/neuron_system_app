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
end
