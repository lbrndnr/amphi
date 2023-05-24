defmodule Amphi.Models.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    belongs_to :paper, Amphi.Models.Paper
    has_many :comments, Amphi.Models.Comment
    many_to_many :liked_by_users, Amphi.Models.User, join_through: "post_likes"
    field :likes, :integer, default: 0, virtual: true

    timestamps()
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:paper_id])
  end
end
