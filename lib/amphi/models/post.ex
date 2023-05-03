defmodule Amphi.Models.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    has_one :paper, Amphi.Models.Paper
    has_many :comments, Amphi.Models.Comment
    belongs_to :user, Amphi.Models.User
    many_to_many :liked_by_users, Amphi.Models.User, join_through: "posts_likes"
    field :likes, :integer, default: 0, virtual: true

    timestamps()
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:user_id])
  end
end
