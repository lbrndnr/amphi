defmodule Amphi.Models.Paper do
    use Ecto.Schema
    import Ecto.Changeset

    schema "papers" do
        field :title, :string
        field :url, :string
        field :abstract, :string
        many_to_many :authors, Amphi.Models.Author, join_through: "paper_authors"
        belongs_to :post, Amphi.Models.Post

        timestamps()
    end

    def changeset(paper, attrs) do
        paper
        |> cast(attrs, [:title, :url, :abstract])
        |> validate_required([:title, :url, :abstract])
        |> validate_length(:title, min: 1, max: 100)
        |> validate_length(:url, min: 5, max: 100)
    end
end
