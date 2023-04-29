defmodule AmphiWeb.PostLive.Show do
  use AmphiWeb, :live_view

  alias Amphi.Models.Comment
  alias Amphi.Posts
  alias Amphi.Comments

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    form = Comments.change_comment(%Comment{})
    |> to_form()

    # comments = Comments.list_comments()

    {:noreply, socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:form, form)
    |> assign(:post, Posts.get_post!(id, [:paper, :user]))}
  end

  @impl true
  def handle_event("comment", %{"comment" => comment_params}, socket) do
    params = %{comment_params |
      "user" => socket.assigns.current_user,
      "post" => socket.assigns.post
    }
    comment = Comments.create_comment(params)

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Post"
  defp page_title(:edit), do: "Edit Post"
end
