defmodule Amphi.Papers do

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

    defp get_paper_meta(url) do
        res = Crawly.fetch(url)
        {:ok, html} = Floki.parse_document(res.body)

        title = html
        |> Floki.find(".citation__title")
        |> Floki.text

        abstract = html
        |> Floki.find(".abstractSection .abstractInFull")
        |> Floki.text

        author_names = html
        |> Floki.find(".loa__author-name")
        |> Enum.map(fn node -> Floki.text(node) end)

        %{
           "title" => title,
           "abstract" => abstract,
           "authors" => Enum.map(author_names, fn a -> %{name: a} end),
           "url" => url
        }
    end

    def create_paper_by(url) do
        paper_meta = get_paper_meta(url)

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
