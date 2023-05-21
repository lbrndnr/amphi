defmodule AmphiWeb.Component.SearchBar do
  use AmphiWeb, :live_component

  alias Amphi.Papers

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
    results = Papers.query_paper(text)
    |> Enum.map(fn r ->
      %{title: r.title, context: r.text}
    end)

    {:noreply, socket
    |> assign(:results, results)}
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
