defmodule Amphi.Authors do

  alias Amphi.Repo
  alias Amphi.Models.Author

  def get_author(id) do
      Repo.get(Author, id)
  end

  def list_authors do
     Repo.all(Author)
  end

  def get_author_by(params) do
    Repo.get_by(Author, params)
end

  def create_author(params \\ %{}) do
      %Author{}
      |> Author.changeset(params)
      |> Repo.insert()
  end

end
