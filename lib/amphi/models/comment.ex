defmodule Amphi.Models.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    belongs_to :user, Amphi.Models.User
    belongs_to :post, Amphi.Models.Post
    belongs_to :response, Amphi.Models.Comment
    many_to_many :liked_by_users, Amphi.Models.User, join_through: "comment_likes"
    field :likes, :integer, default: 0, virtual: true
    field :text, :string
    field :rects, {:array, :float}
    field :comment_height, :integer
    field :page_idx, :integer

    timestamps()
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:user_id, :post_id, :response_id, :likes, :text, :rects, :comment_height, :page_idx])
    |> validate_required([:user_id, :post_id, :likes, :text])
    |> validate_length(:text, min: 1, max: 1000)
  end
end
