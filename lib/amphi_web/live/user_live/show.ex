defmodule AmphiWeb.UserLive.Show do
  use AmphiWeb, :live_view

  alias Amphi.Users

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    user = Users.get_user!(id, [:authors, posts: :paper])

    {:noreply,
     socket
     |> assign(:page_title, user.name)
     |> assign(:user, user)}
  end
end
