defmodule AmphiWeb.Component.SearchBar do
  use AmphiWeb, :live_component

  alias Amphi.MongoDBRepo
  alias Amphi.Posts
  alias Amphi.Papers
  import Ecto.Query
  import Mongo.Ecto.Helpers

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-2/5">
      <div class="relative">
        <input type="search" phx-keyup="prompt" phx-debounce phx-target={@myself} class="w-full rounded-lg border border-gray-200" autocomplete="off" placeholder="Search"/>

        <!-- search result -->
        <%= for item <- @results do %>
          <div class="absolute z-10 w-full border rounded-lg shadow divide-y max-h-72 overflow-y-auto bg-white mt-1">
            <a class="block p-2 hover:bg-indigo-50" href="#">
              <b><%= item.title %></b>
              <p class="line-clamp-2"><%= item.context %></p>
            </a>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, socket
    |> assign(:results, [])}
  end

  @impl true
  def handle_event("prompt", %{"value" => text}, socket) do
    results = case String.length(text) do
      0 -> []
      _ ->
        query = from p in MPaper,
          where: fragment(title: ["$regex": ^text, "$options": "i"]) or fragment(text: ["$regex": ^text, "$options": "i"]),
          select: p
        results = MongoDBRepo.all(query)

        Enum.map(results, fn r ->
          %{title: r.title, context: r.text}
        end)
    end

    {:noreply, socket
    |> assign(:results, results)}
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end

defmodule MPaper do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "papers" do
    field :title
    field :text
  end
end
