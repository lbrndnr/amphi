defmodule Amphi.Models.User do
    use Ecto.Schema
    import Ecto.Changeset

    schema "users" do
        field :name, :string
        field :email, :string
        field :username, :string
        field :password, :string, virtual: true
        field :password_hash, :string
        has_many :authors, Amphi.Models.Author
        has_many :posts, Amphi.Models.Post
        has_many :comments, Amphi.Models.Comment
        many_to_many :liked_posts, Amphi.Models.Post, join_through: "posts_likes"
        many_to_many :liked_comments, Amphi.Models.Comment, join_through: "comments_likes"

        timestamps()
    end

    def changeset(user, attrs) do
        user
        |> cast(attrs, [:name, :username, :email])
        |> validate_required([:name, :username, :email])
        |> validate_length(:username, min: 2, max: 20)
    end

    def registration_changeset(user, attrs) do
        user
        |> changeset(attrs)
        |> cast(attrs, [:password])
        |> validate_format(:email, ~r/@/)
        |> unique_constraint(:email)
        |> unique_constraint(:username)
        |> validate_required([:password])
        |> validate_length(:password, min: 8, max: 100)
        |> put_pass_hash()
    end

    defp put_pass_hash(changeset) do
        case changeset do
            %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
                put_change(changeset, :password_hash, Pbkdf2.hash_pwd_salt(pass))
            _ ->
                changeset
        end
    end

end
