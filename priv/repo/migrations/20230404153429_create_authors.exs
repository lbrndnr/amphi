defmodule Amphi.Repo.Migrations.CreateAuthors do
  use Ecto.Migration

  def change do
    create table(:authors) do
      add :name, :string
      add :email, :string
      add :affiliation, :string
      add :user_id, references(:users)
      add :paper_id, references(:papers)

      timestamps()
    end

    create table(:paper_authors, primary_key: false) do
      add :paper_id, references(:papers, on_delete: :delete_all), primary_key: true
      add :author_id, references(:authors, on_delete: :delete_all), primary_key: true
    end

    alter table(:users) do
      add :author_id, references(:authors)
    end

    alter table(:papers) do
      add :abstract, :text
    end

  end

end
