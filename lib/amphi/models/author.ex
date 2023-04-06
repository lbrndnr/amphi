defmodule Amphi.Models.Author do
    use Ecto.Schema
    import Ecto.Changeset


    schema "authors" do
        field :name, :string
        field :email, :string
        field :affiliation, :string
        belongs_to :user, Amphi.Models.User
        many_to_many :papers, Amphi.Models.Paper, join_through: "paper_authors"

        timestamps()
    end

    def changeset(author, attrs) do
        author
        |> cast(attrs, [:name, :email, :affiliation])
    end

end
