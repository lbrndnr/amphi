defmodule AmphiWeb.SessionController do
    use AmphiWeb, :controller

    alias Amphi.Users
    alias Amphi.Models.User

    def new(conn, _params) do
        render(conn, :new)
    end

    def create(conn, %{"session" => %{"username" => username, "password" => password}}) do
        case Users.authenticate(username, password) do
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