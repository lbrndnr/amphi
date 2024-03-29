defmodule AmphiWeb.Component.SearchBar do
  use AmphiWeb, :live_component

  alias Amphi.Papers
  alias Amphi.Posts
  import Ecto.Changeset

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-2/5">
      <div class="relative">
        <.form
          for={@form}
          as="query"
          id="search-form"
          phx-target={@myself}
          phx-change="prompt"
          phx-debounce
        >
          <.input field={@form[:query]} type="search" autocomplete="off" placeholder="Search"/>
        </.form>

        <!-- search result -->
        <%= for item <- @results do %>
          <div class="absolute z-10 w-full border rounded-lg shadow divide-y max-h-72 overflow-y-auto bg-white mt-1">
            <button class="text-left block p-2 hover:bg-indigo-50 bg-white" phx-click="show" phx-value-id={item.id} phx-target={@myself}>
              <b><%= item.title %></b>
              <p class="line-clamp-2"><%= item.text %></p>
            </button>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def update(_assigns, socket) do
    {:ok, socket
    |> assign(:form, %{} |> to_form())
    |> assign(:results, [])}
  end

  @impl true
  def handle_event("prompt", %{"query" => query}, socket) do
    results = query
    |> Papers.query_paper()

    {:noreply, socket
    |> assign(:results, results)}
  end

  @impl true
  def handle_event("show", %{"id" => paper_id}, socket) do
    post = case Posts.get_post_for_paper(paper_id) do
      paper -> paper
      nil -> Posts.create_post(%{"paper_id" => paper_id})
    end

    {:noreply, socket
      |> redirect(to: ~p"/posts/#{post.id}") }
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
