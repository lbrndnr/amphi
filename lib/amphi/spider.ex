defmodule Spider do

  def get_paper_meta(url) do
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

end
