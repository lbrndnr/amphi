defmodule Amphi.Repo.Migrations.CreatePapers do
  use Ecto.Migration

  def change do
    create table("papers") do
      add :title, :string
      add :url, :string, null: false

      timestamps()
    end

    create unique_index(:papers, [:url])
  end
end
