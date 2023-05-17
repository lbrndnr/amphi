defmodule AmphiWeb.SessionController do
    use AmphiWeb, :controller

    def new(conn, _params) do
        render(assign(conn, :current_user, nil), :new)
    end

    def create(conn, %{"user" => %{"username" => username, "password" => password}}) do
        case Amphi.Users.authenticate(username, password) do
            {:ok, user} ->
                conn
                |> AmphiWeb.Auth.login(user)
                |> put_flash(:info, "Logged in.")
                |> redirect(to: ~p"/")
            {:error, _reason} ->
                conn
                |> put_flash(:error, "Invalid username or password.")
                |> render(:new)
        end
    end

    def delete(conn, _params) do
        conn
        |> AmphiWeb.Auth.logout()
        |> put_flash(:info, "Logged out.")
        |> redirect(to: ~p"/")
    end

end
