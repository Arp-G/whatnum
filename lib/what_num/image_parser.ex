defmodule ImageParser do

  # Load pixel values from a png image
  # Uses the Pixels dependency to read pixel data from PNG image
  def load_img(path) do
    {:ok, %Pixels{data: data}} = Pixels.read_file(path)
    data
  end

  # Use ImageMagick to resize the image to 28 * 28
  # Also, converts image to monochrome(black and white)
  def resize(input_file_path) do
    System.cmd("convert", [
      input_file_path,
      "-resize",
      "28x28!",
      "-monochrome",
      "/tmp/output.png"
    ])
  end

  # Take image pixel data and read it as dx3-ubyte which is the MNIST data set format
  # Return a tensor created from the image data
  def parse_and_make_tensor(image_data) do
    image_data
    |> :binary.bin_to_list()                     # Convert Image binray to list
    |> Enum.chunk_every(4)                       # Chunk every 4 values to get a singal RGBA pixel
    |> Enum.map(fn                               # Since we are processing a back and white image there
      [0, 0, 0, 255] -> 0                        # can be only two pixels values rgba(0, 0, 0, 255) -> Black and rgba(255,255, 255, 255) -> White
      [255, 255, 255, 255] -> 255                # We map Black pixels to a single value 0 and white pixels to a single value 255
    end)
    |> :binary.list_to_bin()                     # Convert list back to binary
    |> Nx.from_binary({:u, 8})                   # Create a Nx tensor
  end

  def prepare_img_tensor(img_path \\ "/tmp/output.png") do
    img_path
    |> load_img()
    |> parse_and_make_tensor()
  end

  # Helper method to visualize the headmap of a loaded image
  def visualize(img_path \\ "/tmp/output.png") do
    img_path
    |> prepare_img_tensor()
    |> Nx.reshape({28, 28})
    |> Nx.to_heatmap()
  end

  # Predict the number in the image using the neural network
  def predict(img_path \\ "/tmp/input.png") do
    resize(img_path)

    TrainingCache.get_weights()                                                 # Train neural network and get weights after training
    |> MNIST.predict(prepare_img_tensor("/tmp/output.png"))                     # Predict given image
    |> Nx.backend_transfer()                                                    # Transfer Tensor backend to elixir from EXLA
    |> Nx.to_flat_list()                                                        # Convert out tensor to list
    |> Enum.with_index()                                                        # Add indexes to the output list
    |> Enum.sort(fn {val1, _index1}, {val2, _index2} -> val1 >= val2 end)       # Sort to get the index of the predictions having maximum probabity
    |> Enum.take(3)                                                             # Pick top 3 predictions
    |> inspect
  end
end
