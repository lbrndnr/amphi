defmodule Amphi.Papers do

    alias Amphi.Repo
    alias Amphi.Models.Paper
    alias Ecto.Changeset

    def get_paper(id, assocs \\ []) do
        paper = Repo.get(Paper, id)
        case assocs do
            [] -> paper
            assocs -> Repo.preload(paper, assocs)
        end
    end

    def get_paper_by(attrs) do
        Repo.get_by(Paper, attrs)
    end

    def list_papers do
       Repo.all(Paper)
    end

    def change_paper(%Paper{} = paper) do
        Paper.changeset(paper, %{})
    end

    def create_paper(attrs \\ %{}) do
        %Paper{}
        |> Paper.changeset(attrs)
        |> Changeset.put_assoc(:authors, attrs["authors"])
        |> Repo.insert()
    end

end
