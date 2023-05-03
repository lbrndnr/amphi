defmodule Amphi.Models.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    has_one :paper, Amphi.Models.Paper
    has_many :comments, Amphi.Models.Comment
    belongs_to :user, Amphi.Models.User
    field :likes, :integer, default: 0
    field :liked_by, {:array, :integer}, default: []

    timestamps()
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:likes, :user_id, :liked_by])
  end
end
