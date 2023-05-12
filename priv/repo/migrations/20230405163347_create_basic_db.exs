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

      timestamps()
    end

    create table(:posts_likes, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all), primary_key: true
      add :post_id, references(:posts, on_delete: :delete_all), primary_key: true
    end

    create table(:papers) do
      add :title, :string
      add :abstract, :text
      add :url, :string, null: false
      add :pdf_url, :string
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

    create table(:papers_authors, primary_key: false) do
      add :paper_id, references(:papers, on_delete: :delete_all), primary_key: true
      add :author_id, references(:authors, on_delete: :delete_all), primary_key: true
    end

    create table(:comments) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :post_id, references(:posts, on_delete: :nothing), null: false
      add :response_id, references(:comments, on_delete: :nothing)
      add :likes, :integer
      add :text, :text
      add :rects, {:array, :float}
      add :comment_height, :integer

      timestamps()
    end

    create table(:comments_likes, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all), primary_key: true
      add :comment_id, references(:comments, on_delete: :delete_all), primary_key: true
    end

    create index(:comments, [:post_id])
    create index(:comments, [:response_id])
    create index(:comments, [:user_id])
    create index(:posts, [:user_id])
    create unique_index(:papers, [:url])
    create unique_index(:papers, [:post_id])
    create unique_index(:users, [:username, :email])
    create unique_index(:papers_authors, [:paper_id, :author_id])
    create unique_index(:posts_likes, [:user_id, :post_id])
    create unique_index(:comments_likes, [:user_id, :comment_id])
  end
end
