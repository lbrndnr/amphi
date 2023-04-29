defmodule AmphiWeb.PostLive.Index do
  use AmphiWeb, :live_view

  alias Amphi.Posts
  alias Amphi.Models.Post

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :posts, Posts.list_posts([:paper])) }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Feed")
  end

  @impl true
  def handle_info({AmphiWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    {:noreply, stream_insert(socket, :posts, post)}
  end

end
