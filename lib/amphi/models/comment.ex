defmodule Amphi.Models.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    belongs_to :user, Amphi.Models.User
    belongs_to :post, Amphi.Models.Post
    belongs_to :response, Amphi.Models.Comment
    field :likes, :integer, default: 0
    field :text, :string

    timestamps()
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:user_id, :post_id, :response_id, :likes, :text])
    |> validate_required([:user_id, :post_id, :likes, :text])
    |> validate_length(:text, min: 1, max: 1000)
  end
end
