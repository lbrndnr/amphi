defmodule AmphiWeb.PostLive.FormComponent do
  use AmphiWeb, :live_component

  alias Amphi.Posts
  alias Amphi.Papers

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Paste a URL to a paper you want to share.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="post-form"
        phx-target={@myself}
        phx-submit="save"
      >
        <.input field={@form[:url]} type="url" label="URL" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Post</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{post: post} = assigns, socket) do
    changeset = Posts.change_post(post)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("save", %{"post" => post_params}, socket) do
    url = post_params["url"]
    paper = case Papers.get_paper_by(url: url) do
        nil -> Papers.create_paper_by(url)
        paper -> {:ok, paper}
    end

    with {:ok, paper} <- paper,
          post_params = %{"paper" => paper},
          {:ok, post} <- Posts.create_post(post_params) do

        notify_parent({:saved, post})
        {:noreply,
        socket
        |> put_flash(:info, "Post created successfully")
        |> push_patch(to: "/")}
    else
        {:error, %Ecto.Changeset{} = changeset} ->
          require Logger
          Logger.debug changeset.errors
          {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
