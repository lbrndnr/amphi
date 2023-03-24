defmodule Amphi.Users do

    alias Amphi.Repo
    alias Amphi.Models.User

    def get_user(id) do
        Repo.get(User, id)
    end

    def get_user_by(params) do
        Repo.get_by(User, params)
    end

    def change_user(%User{} = user) do
        User.changeset(user, %{})
    end

    def insert_user(params \\ %{}) do
        %User{}
        |> User.changeset(params)
        |> Repo.insert()
    end

    def change_registration(%User{} = user, params) do
        User.registration_changeset(user, params)
    end

    def register_user(params \\ %{}) do
        %User{}
        |> User.registration_changeset(params)
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