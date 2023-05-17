defmodule AmphiWeb.InitAssigns do

  import Phoenix.LiveView
  import Phoenix.Component

  def on_mount(:default, _params, session, socket) do
    user_id = session["user_id"]
    user = user_id && Amphi.Users.get_user(user_id)

    {:cont,
    socket
    |> assign(:page_title, "Amphi")
    |> assign(:current_user, user)}
  end

end
