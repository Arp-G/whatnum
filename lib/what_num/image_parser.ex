defmodule ImageParser do
  # Load pixel values from a png image
  def load_img(path) do
    {:ok, %Pixels{data: data}} = Pixels.read_file(path)
    data
  end

  def resize(input_file_path) do
    System.cmd("convert", [
      input_file_path,
      "-resize",
      "28x28!",
      "/tmp/output.png"
    ])
  end

  def parse_and_make_tensor(image_data) do
    image_data
    |> :binary.bin_to_list()
    |> Enum.with_index()
    |> Enum.filter(fn {_pixel, index} -> rem(index, 4) == 0 end)
    |> Enum.map(fn {pixel, _index} -> pixel end)
    |> :binary.list_to_bin()
    |> Nx.from_binary({:u, 8})
  end

  def prepare_img_tensor(img_path \\ "/tmp/output.png") do
    img_path
    |> load_img()
    |> parse_and_make_tensor()
  end

  def visualize(img_path \\ "/tmp/output.png") do
    img_path
    |> prepare_img_tensor()
    |> Nx.reshape({28, 28})
    |> Nx.to_heatmap()
  end

  def predict(img_path \\ "/tmp/input.png") do
    resize(img_path)

    if Process.whereis(TrainingCache) do
      TrainingCache.get_weights()
    else
      weights = MNIST.run()
      TrainingCache.start_link(weights)
      weights
    end
    |> MNIST.predict(prepare_img_tensor("/tmp/output.png"))
    |> Nx.backend_transfer()
    |> Nx.to_flat_list()
    |> Enum.with_index()
    |> Enum.reduce({0, 0}, fn {val, index}, {max, max_index} ->
      if val > max, do: {val, index}, else: {max, max_index}
    end)
    |> inspect
  end
end
