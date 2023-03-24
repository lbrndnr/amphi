defmodule AmphiWeb.UserController do
    use AmphiWeb, :controller

    alias Amphi.Users
    alias Amphi.Models.User

    def new(conn, _params) do
        changeset = Users.change_registration(%User{}, %{})
        render(conn, :new, changeset: changeset)
    end

    def create(conn, %{"user" => user_params}) do
        case Users.register_user(user_params) do
            {:ok, user} ->
                conn
                |> AmphiWeb.Auth.login(user)
                |> put_flash(:info, "#{user.name} created!")
                |> redirect(to: ~p"/")
            {:error, %Ecto.Changeset{} = changeset} ->
                conn
                |> put_flash(:error, "Error")
                |> render(:new, changeset: changeset)
        end
    end

end