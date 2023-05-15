defmodule AmphiWeb.PostLive.Show do
  use AmphiWeb, :live_view

  alias Amphi.Models.Comment
  alias Amphi.Posts
  alias Amphi.Users
  alias Amphi.Comments

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    form = Comments.change_comment(%Comment{})
    |> to_form()

    post = Posts.get_post!(id, [:paper, :user])
    comments = Comments.list_comments(post, [:user])

    {:noreply, socket
    |> assign(:page_title, post.paper.title)
    |> assign(:form, form)
    |> assign(:post, post)
    |> stream(:comments, comments)}
  end

  @impl true
  @spec handle_event(<<_::48, _::_*8>>, any, map) :: {:noreply, map}
  def handle_event("get_comment_rects", _, socket) do
    post = socket.assigns.post
    comments = Comments.list_comments(post)
    rects = Enum.map(comments, &(&1.rects))
    idx = Enum.map(comments, &(&1.page_idx))
    {:noreply, push_event(socket, "get_comment_rects", %{rects: rects, idx: idx})}
  end

  @impl true
  def handle_event("like_post", _, socket) do
    user = socket.assigns.current_user
    post = socket.assigns.post
    case Users.like_post(user, post) do
      {:ok, _user} ->
        post = Posts.get_post!(post.id, [:paper, :user])
        {:noreply, socket
          |> put_flash(:info, "Liked.")
          |> assign(:post, post)}
      {:error, %Ecto.Changeset{} = changeset} -> {:noreply, socket |> put_flash(:error, "An error occurred: #{changeset.errors}")}
    end
  end

  @impl true
  def handle_event("like_comment", %{"id" => comment_id}, socket) do
    user = socket.assigns.current_user
    comment = Comments.get_comment!(comment_id)
    case Users.like_comment(user, comment) do
      {:ok, _user} ->
        # New comment with updated likes count
        comment = Comments.get_comment!(comment_id)
        {:noreply, socket
        |> put_flash(:info, "Liked comment.")
        |> stream_insert(:comments, comment |> Amphi.Repo.preload([:user]))}
      {:error, %Ecto.Changeset{} = changeset} -> {:noreply, socket |> put_flash(:error, "An error occurred: #{changeset.errors}")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => comment_id}, socket) do
    comment = Comments.get_comment!(comment_id)
    case Comments.delete_comment(comment) do
      {:ok, _} -> {:noreply, socket
        |> stream_delete(:comments, comment)
        |> put_flash(:info, "Comment deleted.")}
      {:error, %Ecto.Changeset{} = changeset} -> {:noreply, socket |> put_flash(:error, "An error occurred: #{changeset.errors}")}
    end
  end

  @impl true
  def handle_event("comment", %{"comment" => comment_params}, socket) do
    params = Map.merge(comment_params, %{
      "user_id" => socket.assigns.current_user.id,
      "post_id" => socket.assigns.post.id,
    })

    case Comments.create_comment(params) do
      {:ok, comment} ->
        {:noreply, socket
        |> put_flash(:info, "Comment created successfully")
        |> stream_insert(:comments, comment |> Amphi.Repo.preload([:user]))}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket
        |> put_flash(:error, "An error occurred: #{changeset.errors}")}
    end
  end

  @impl true
  def handle_event("comment_thread", %{"id" => comment_id}, socket) do
    {:noreply, socket |> push_redirect(to: "/comments/#{comment_id}")}
  end

end
