defmodule Amphi.Repo.Migrations.CreateBasicDb do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string, null: false
      add :username, :string, null: false
      add :password_hash, :string

      timestamps()
    end

    create table(:posts) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :likes, :integer

      timestamps()
    end

    create table(:papers) do
      add :title, :string
      add :abstract, :text
      add :url, :string, null: false
      add :post_id, references(:posts)

      timestamps()
    end

    create table(:authors) do
      add :name, :string
      add :email, :string
      add :affiliation, :string
      add :user_id, references(:users)

      timestamps()
    end

    create table(:paper_authors, primary_key: false) do
      add :paper_id, references(:papers, on_delete: :delete_all), primary_key: true
      add :author_id, references(:authors, on_delete: :delete_all), primary_key: true
    end

    create table(:comments) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :post_id, references(:posts, on_delete: :nothing), null: false
      add :response_id, references(:comments, on_delete: :nothing)
      add :likes, :integer
      add :text, :text

      timestamps()
    end

    create index(:comments, [:post_id])
    create index(:comments, [:response_id])
    create index(:comments, [:user_id])
    create index(:posts, [:user_id])
    create unique_index(:papers, [:url])
    create unique_index(:papers, [:post_id])
    create unique_index(:users, [:username, :email])
  end
end
