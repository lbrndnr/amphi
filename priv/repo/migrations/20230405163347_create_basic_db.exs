defmodule Amphi.Repo.Migrations.CreateBasicDb do
  use Ecto.Migration

  # def down do
  #   execute "DROP EXTENSION fuzzystrmatch"
  #   execute "DROP EXTENSION pg_trgm"
  # end

  def change do
    execute "CREATE EXTENSION pg_trgm"
    execute "CREATE EXTENSION fuzzystrmatch"

    create table(:users) do
      add :name, :string
      add :email, :string, null: false
      add :username, :string, null: false
      add :password_hash, :string

      timestamps(default: fragment("NOW()"))
    end

    create table(:papers) do
      add :title, :string, null: false
      add :abstract, :text
      add :text, :text
      add :url, :string
      add :pdf_url, :string
      add :keywords, {:array, :string}

      timestamps(default: fragment("NOW()"))
    end

    create table(:posts) do
      add :paper_id, references(:papers, on_delete: :nothing), null: false

      timestamps(default: fragment("NOW()"))
    end

    create table(:post_likes, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all), primary_key: true
      add :post_id, references(:posts, on_delete: :delete_all), primary_key: true
    end

    create table(:paper_references, primary_key: false) do
      add :reference_id, references(:papers, on_delete: :delete_all), primary_key: true
      add :citation_id, references(:papers, on_delete: :delete_all), primary_key: true
    end

    create table(:authors) do
      add :name, :string
      add :email, :string
      add :affiliation, :string
      add :user_id, references(:users)

      timestamps(default: fragment("NOW()"))
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
      add :rects, {:array, :float}
      add :comment_height, :integer
      add :page_idx, :integer

      timestamps(default: fragment("NOW()"))
    end

    create table(:comment_likes, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all), primary_key: true
      add :comment_id, references(:comments, on_delete: :delete_all), primary_key: true
    end

    create index(:comments, [:post_id])
    create index(:comments, [:response_id])
    create index(:comments, [:user_id])
    create unique_index(:posts, [:paper_id])
    create unique_index(:papers, [:url])
    create unique_index(:papers, [:pdf_url])
    create unique_index(:users, [:username])
    create unique_index(:users, [:email])
    create unique_index(:authors, [:email])
    create unique_index(:paper_authors, [:paper_id, :author_id])
    create unique_index(:paper_references, [:reference_id, :citation_id])
    create unique_index(:post_likes, [:user_id, :post_id])
    create unique_index(:comment_likes, [:user_id, :comment_id])
  end
end
