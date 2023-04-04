defmodule Amphi.Models.User do
    use Ecto.Schema
    import Ecto.Changeset

    schema "users" do
        field :name, :string
        field :email, :string
        field :username, :string
        field :password, :string, virtual: true
        field :password_hash, :string
        has_many :author, Amphi.Models.Author

        timestamps()
    end

    def changeset(user, params) do
        user
        |> cast(params, [:name, :username, :email])
        |> validate_required([:name, :username, :email])
        |> validate_length(:username, min: 2, max: 20)
    end

    def registration_changeset(user, params) do
        user
        |> changeset(params)
        |> cast(params, [:password])
        |> validate_format(:email, ~r/@/)
        |> unique_constraint(:email)
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
