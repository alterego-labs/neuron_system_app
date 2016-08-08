defmodule NeuronSystem.BackProp.Utils.Calculations do
  @moduledoc """
  In this module are encapsulated all calculations for Back Prop algorithm.
  """

  @learning_speed 0.4

  @doc """
  Calculates a lapse for an output neuron.
  """
  @spec out_lapse(float, float, float) :: float
  def out_lapse(calculated_output, d_calculated_output, needed_output) do
    (needed_output - calculated_output) * d_calculated_output
  end

  @doc """
  Calculates a delta value for a weight of a connection.
  """
  @spec delta_weight(float, float) :: float
  def delta_weight(lapse, income) do
    @learning_speed * lapse * income
  end

  @doc """
  Calculates new weight of a connection by old one and delta value.
  """
  @spec new_weight(float, float) :: float
  def new_weight(weight, delta_w) do
    weight + delta_w
  end

  @doc """
  Calculates connection's lapse by output lapse and connection's weight.
  """
  @spec connection_lapse(float, float) :: float
  def connection_lapse(lapse, weight) do
    lapse * weight
  end
end
