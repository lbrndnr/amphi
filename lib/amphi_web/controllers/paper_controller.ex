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
      paper = Papers.get_paper(id, [:authors])
      render(conn, :show, paper: paper)
   end

   def new(conn, _params) do
      changeset = Papers.change_paper(%Paper{})
      render(conn, :new, changeset: changeset)
   end

end
