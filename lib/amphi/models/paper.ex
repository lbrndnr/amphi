defmodule Amphi.Models.Paper do
    use Ecto.Schema
    import Ecto.Changeset

    schema "papers" do
        field :title, :string
        field :abstract, :string
        field :text, :string
        field :url, :string
        field :pdf_url, :string
        field :keywords, {:array, :string}
        many_to_many :authors, Amphi.Models.Author, join_through: "paper_authors"
        many_to_many :references, Amphi.Models.Paper, join_through: "paper_references"
        many_to_many :citations, Amphi.Models.Paper, join_through: "paper_references"
        has_one :post, Amphi.Models.Post

        timestamps()
    end

    def changeset(paper, attrs) do
        paper
        |> cast(attrs, [:title, :url, :pdf_url, :abstract])
        |> validate_required([:title, :url, :abstract])
        |> validate_length(:title, min: 1, max: 100)
        |> validate_length(:url, min: 5, max: 100)
    end
end
