defmodule Amphi.Users do

    alias Amphi.Repo
    alias Amphi.Models.User
    alias Ecto.Changeset

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

    def change_user(%User{} = user, attrs \\ %{}) do
        User.changeset(user, attrs)
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

    def like_post(user, post) do
        user = Repo.preload(user, :liked_posts)

        Changeset.change(user)
        |> Changeset.put_assoc(:liked_posts, [post | user.liked_posts])
        |> Repo.update
    end

    def like_comment(user, comment) do
        user = Repo.preload(user, :liked_comments)

        Changeset.change(user)
        |> Changeset.put_assoc(:liked_comments, [comment | user.liked_comments])
        |> Repo.update
    end

    def unlike_post(user, post) do
        user = Repo.preload(user, :liked_posts)
        liked_posts = user.liked_posts |> Enum.filter(fn p -> p.id != post.id end)

        Changeset.change(user)
        |> Changeset.put_assoc(:liked_posts, liked_posts)
        |> Repo.update
    end

end
