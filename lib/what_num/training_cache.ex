defmodule TrainingCache do
  use Agent

  def start_link(weights) do
    Agent.start_link(fn -> weights end, name: __MODULE__)
  end

  def get_weights do
    Agent.get(__MODULE__, & &1)
  end
end
