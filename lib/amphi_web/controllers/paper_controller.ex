defmodule AmphiWeb.PaperController do
   use AmphiWeb, :controller

   alias Amphi.Papers
   alias Amphi.Authors
   alias Amphi.Models.Paper

   plug :authenticate_user when action in [:new]

   def index(conn, _params) do
      papers = Papers.list_papers()
      render(conn, :index, papers: papers)
   end

   def show(conn, %{"id" => id}) do
      paper = Papers.get_paper(id)
      render(conn, :show, paper: paper)
   end

   def new(conn, _params) do
      changeset = Papers.change_paper(%Paper{})
      render(conn, :new, changeset: changeset)
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
         "authors" => Enum.map(author_names, fn a -> %{name: a} end)
      }
   end

    def create(conn, %{"paper" => paper_params}) do
         paper_meta = get_paper_meta(paper_params["url"])
         authors = Enum.map(paper_meta["authors"], fn author_params ->
            author = case Authors.get_author_by(author_params) do
              nil -> Authors.insert_author(author_params)
              author -> {:ok, author}
            end

            elem(author, 1)
         end)

         paper_params = paper_params
         |> Map.merge(paper_meta)
         |> Map.put("authors", authors)

         case Papers.insert_paper(paper_params) do
            {:ok, paper} ->
                conn
                |> put_flash(:info, "#{paper.title} created!")
                |> redirect(to: ~p"/")
            {:error, %Ecto.Changeset{} = changeset} ->
                render(conn, :new, changeset: changeset)
         end
    end

end
