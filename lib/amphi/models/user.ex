defmodule Amphi.Models.User do
    use Ecto.Schema
    import Ecto.Changeset

    schema "users" do
        field :name, :string
        field :email, :string
        field :username, :string

        timestamps()
    end
end