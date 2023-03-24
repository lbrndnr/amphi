defmodule AmphiWeb.PaperController do
   use AmphiWeb, :controller

   alias Amphi.Papers
   alias Amphi.Models.Paper

   plug :authenticate when action in [:new]

   defp authenticate(conn, _opts) do
       if conn.assigns.current_user do
           conn
       else
           conn
           |> put_flash(:error, "You must be logged in to access that page.")
           |> redirect(to: ~p"/")
           |> halt()
       end
   end

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

    def create(conn, %{"paper" => paper_params}) do
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