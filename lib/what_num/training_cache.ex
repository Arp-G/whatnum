# This genserver just stores the trained neural network weights to avoid retraining it every time we need a prediction
defmodule TrainingCache do
  use Agent

  def start_link(weights) do
    Agent.start_link(fn -> weights end, name: __MODULE__)
  end

  def get_weights do
    if Process.whereis(TrainingCache) do
      Agent.get(__MODULE__, & &1)
    else
      weights = MNIST.run()
      TrainingCache.start_link(weights)
      weights
    end
  end
end
