defmodule WhatNumWeb.PageLive do
  use WhatNumWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, results: "Nothing !")}
  end

  @impl true
  def handle_event("clear_canvas", _, socket) do
    {:noreply, push_event(socket, "clear_canvas", %{})}
  end

  @impl true
  def handle_event("save_canvas", _, socket) do
    {:noreply, push_event(socket, "save_canvas", %{})}
  end

  @impl true
  def handle_event("send_image", %{"image_data" => base64_png}, socket) do
    save_bas64_encoded_image(base64_png)

    {:noreply, assign(socket, results: ImageParser.predict("#{System.tmp_dir()}/input.png"))}
  end

  defp save_bas64_encoded_image(base64_png) do
    "data:image/png;base64," <> raw_image = base64_png

    "#{System.tmp_dir()}/input.png"
    |> File.write!(Base.decode64!(raw_image))
  end
end
