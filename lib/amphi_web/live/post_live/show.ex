defmodule AmphiWeb.PostLive.Show do
  use AmphiWeb, :live_view

  alias Amphi.Posts

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign(socket, :current_user, session["current_user"])}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:current_user, nil)
     |> assign(:post, Posts.get_post!(id, [:paper, :user]))}
  end

  defp page_title(:show), do: "Show Post"
  defp page_title(:edit), do: "Edit Post"
end
