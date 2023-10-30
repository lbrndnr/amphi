defmodule Amphi.Papers do

    import Ecto.Query
    alias Amphi.Repo
    alias Amphi.Models.Paper
    alias Amphi.Models.Author
    alias Ecto.Changeset
    alias Amphi.Authors

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

    def query_paper(query) do
        from(p in Paper,
        where: fragment("SIMILARITY(?, ?) > 0",  p.title, ^query),
        order_by: fragment("LEVENSHTEIN(?, ?)", p.title, ^query))
        |> Repo.all()
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

    def create_paper_by(url) do
        paper_meta = Spider.get_paper_meta(url)

        authors = paper_meta["authors"]
        |> Enum.reduce_while({:ok, []}, fn author_params, {_, acc} ->
            with nil <- Authors.get_author_by(author_params),
                {:ok, author} <- Authors.create_author(author_params) do
                {:cont, {:ok, acc ++ [author]}}
            else
                %Author{} = author -> {:cont, {:ok, acc ++ [author]}}
                {:error, %Ecto.Changeset{} = changeset} -> {:halt, {:error, changeset}}
            end
        end)

        case authors do
            {:ok, authors} ->
                paper_params = %{paper_meta | "authors" => authors }
                create_paper(paper_params)
            {:error, changeset} -> {:error, changeset}
        end
    end

end
