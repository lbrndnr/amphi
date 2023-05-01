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

        attributes = html
        |> Floki.find("head meta")
        |> Enum.map(fn m -> Tuple.to_list(m) end)
        |> Enum.map(fn [_ | ps] -> ps end)
        |> Enum.map(fn m -> Enum.at(m, 0) |> Enum.into(%{}) end)

        og_url = attributes
        |> Enum.filter(fn m -> m["property"] == "og:url" end)
        |> Enum.at(0, %{})
        |> Map.get("content")

        require Logger
        Logger.debug "OG_URL"
        Logger.debug og_url

        meta = cond do
            og_url =~ "arxiv" -> parse_html(html, :arxiv)
            og_url =~ "dl.acm" -> parse_html(html, :acm)
            true -> %{}
        end

        meta
        |> Map.filter(fn {_, v} -> v != nil end)
        |> Map.put("url", og_url)
    end

    defp parse_html(html, :acm) do
        title = html
        |> Floki.find(".citation__title")
        |> Floki.text

        abstract = html
        |> Floki.find(".abstractSection .abstractInFull")
        |> Floki.text

        author_names = html
        |> Floki.find(".loa__author-name")
        |> Enum.map(&Floki.text/1)

        %{
           "title" => title,
           "abstract" => abstract,
           "authors" => Enum.map(author_names, fn a -> %{name: a} end),
        }
    end

    defp parse_html(html, :arxiv) do
        title = html
        |> Floki.find(".title")
        |> Floki.filter_out("span")
        |> Floki.text

        abstract = html
        |> Floki.find(".abstract")
        |> Floki.filter_out("span")
        |> Floki.text

        author_names = html
        |> Floki.find(".authors a")
        |> Enum.map(&Floki.text/1)

        %{
           "title" => title,
           "abstract" => abstract,
           "authors" => Enum.map(author_names, fn a -> %{name: a} end),
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
