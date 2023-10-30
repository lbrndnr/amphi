defmodule AmphiWeb.CommentLive.Show do
  use AmphiWeb, :live_view
  alias Amphi.Models.Comment
  alias Amphi.Posts
  alias Amphi.Users
  alias Amphi.Comments


  def handle_params(%{"id" => id}, _, socket) do

    comment = Comments.get_comment!(id);
    post = Posts.get_post!(comment.post_id, [:paper]);
    comments = Comments.list_comments_to_comment(comment, [:user])

    {:noreply, socket
    |> assign(:page_title, post.paper.title)
    |> assign(:comment, comment)
    |> assign(:post, post)
    |> stream(:comments, comments)}
  end

  @impl true
  @spec handle_event(<<_::48, _::_*8>>, any, map) :: {:noreply, map}
  def handle_event("get_comment_rects_comment", %{"comment_id" => id}, socket) do
    comment = Comments.get_comment!(id)
    {:noreply, push_event(socket, "get_comment_rects_comment", %{rects: comment.rects, idx: comment.page_idx})}
  end

  @impl true
  def handle_event("comment_button", comment_params, socket) do
    params = Map.merge(comment_params, %{
      "user_id" => socket.assigns.current_user.id,
      "post_id" => socket.assigns.post.id,
      "response_id" => socket.assigns.comment.id,
    })
    IO.inspect(params)

    case Comments.create_comment(params) do
      {:ok, comment} ->
        {:noreply,
          push_event(socket, "loadImage", %{})
          |> put_flash(:info, "Comment created successfully")
          |> stream_insert(:comments, comment |> Amphi.Repo.preload([:user]))}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket
        |> put_flash(:error, "An error occurred: #{changeset.errors}")}
    end
  end

  def handle_info(:reload, socket) do
    {:noreply, socket
      |> push_redirect(to: "/posts/#{socket.assigns.post.id}")}
  end



end
