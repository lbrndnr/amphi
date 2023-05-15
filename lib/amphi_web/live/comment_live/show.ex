defmodule AmphiWeb.CommentLive.Show do
  use AmphiWeb, :live_view
  alias Amphi.Models.Comment
  alias Amphi.Posts
  alias Amphi.Users
  alias Amphi.Comments


  def handle_params(%{"id" => id}, _, socket) do

    comment = Comments.get_comment!(id);
    post = Posts.get_post!(comment.post_id, [:paper, :user]);
    IO.inspect(comment)

    {:noreply, socket
    |> assign(:page_title, post.paper.title)
    |> assign(:comment, comment)
    |> assign(:post, post)}
    # |> stream(:comments, comments)}
  end

  @impl true
  @spec handle_event(<<_::48, _::_*8>>, any, map) :: {:noreply, map}
  def handle_event("get_comment_rects", %{"comment_id" => id}, socket) do
    comment = Comments.get_comment!(id)
    {:noreply, push_event(socket, "get_comment_rects", %{rects: comment.rects, idx: comment.page_idx})}
  end
end
