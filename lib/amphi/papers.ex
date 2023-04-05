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

    def list_papers do
       Repo.all(Paper)
    end

    def change_paper(%Paper{} = paper) do
        Paper.changeset(paper, %{})
    end

    def insert_paper(params \\ %{}) do
        %Paper{}
        |> Paper.changeset(params)
        |> Changeset.put_assoc(:authors, params["authors"])
        |> Repo.insert()
    end

end
