defmodule AmphiWeb.UserLive.New do
  use AmphiWeb, :live_view

  alias Amphi.Users
  alias Amphi.Models.User

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket
    |> assign(trigger_submit: false)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    user = %User{}
    form = Users.change_registration(user, %{})
    |> to_form()

    socket
    |> assign(:page_title, "New User")
    |> assign(:user, user)
    |> assign(:form, form)
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = socket.assigns.user
    |> Users.change_user(user_params)
    |> Map.put(:action, :validate)

    {:noreply, socket
    |> assign(:form, to_form(changeset))}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Users.register_user(user_params) do
      {:ok, user} ->
          {:noreply, socket
          |> put_flash(:info, "#{user.name} created!")
          |> assign(trigger_submit: true)}
      {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, socket
          |> put_flash(:error, changeset.errors)}
    end
  end

end
