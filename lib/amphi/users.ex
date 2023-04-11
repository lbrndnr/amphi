defmodule Amphi.Users do

    alias Amphi.Repo
    alias Amphi.Models.User

    def get_user(id, assocs \\ []) do
        user = Repo.get(User, id)

        case assocs do
            [] -> user
            assocs -> Repo.preload(user, assocs)
        end
    end

    def get_user!(id, assocs \\ []) do
        Repo.get!(User, id)
        |> Repo.preload(assocs)
    end

    def get_user_by(attrs) do
        Repo.get_by(User, attrs)
    end

    def change_user(%User{} = user) do
        User.changeset(user, %{})
    end

    def create_user(attrs \\ %{}) do
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert()
    end

    def change_registration(%User{} = user, attrs) do
        User.registration_changeset(user, attrs)
    end

    def register_user(attrs \\ %{}) do
        %User{}
        |> User.registration_changeset(attrs)
        |> Repo.insert()
    end

    def authenticate(username, password) do
        user = get_user_by(username: username)
        cond do
            user && Pbkdf2.verify_pass(password, user.password_hash) ->
                {:ok, user}
            user ->
                {:error, :unauthorized}
            true ->
                Pbkdf2.no_user_verify()
                {:error, :not_found}
        end
    end

end
