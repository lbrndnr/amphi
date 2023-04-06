defmodule AmphiWeb.PostController do
   use AmphiWeb, :controller

   alias Amphi.Posts
   alias Amphi.Authors
   alias Amphi.Papers
   alias Amphi.Comments
   alias Amphi.Models.Post
   alias Amphi.Models.Paper

   plug :authenticate_user when action in [:new]

   def index(conn, _params) do
      posts = Posts.list_posts([:paper])
      render(conn, :index, posts: posts)
   end

   def show(conn, %{"id" => id}) do
      post = Posts.get_post!(id, [:paper])
      render(conn, :show, post: post)
   end

   def new(conn, _params) do
      changeset = Posts.change_post(%Post{})
      render(conn, :new, changeset: changeset)
   end

   def create(conn, %{"post" => post_params}) do
      url = post_params["url"]
      paper = case Papers.get_paper_by(url: url) do
         nil -> Papers.create_paper_by(url)
         paper -> {:ok, paper}
      end

      with {:ok, paper} <- paper,
           post_params = %{"paper" => paper, "user_id" => get_session(conn, :user_id)},
           {:ok, _post} <- Posts.create_post(post_params) do
         conn
         |> put_flash(:info, "#{paper.title} created!")
         |> redirect(to: ~p"/")
      else
         {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, :new, changeset: changeset)
      end
   end

  # def index(conn, _params) do
  #   posts = Posts.list_posts()
  #   render(conn, :index, posts: posts)
  # end

  # def new(conn, _params) do
  #   changeset = Posts.change_post(%Post{})
  #   render(conn, :new, changeset: changeset)
  # end

  # def create(conn, %{"post" => post_params}) do
  #   case Posts.create_post(post_params) do
  #     {:ok, post} ->
  #       conn
  #       |> put_flash(:info, "Post created successfully.")
  #       |> redirect(to: ~p"/posts/#{post}")

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       render(conn, :new, changeset: changeset)
  #   end
  # end

  # def show(conn, %{"id" => id}) do
  #   post = Posts.get_post!(id)
  #   render(conn, :show, post: post)
  # end

  # def edit(conn, %{"id" => id}) do
  #   post = Posts.get_post!(id)
  #   changeset = Posts.change_post(post)
  #   render(conn, :edit, post: post, changeset: changeset)
  # end

  # def update(conn, %{"id" => id, "post" => post_params}) do
  #   post = Posts.get_post!(id)

  #   case Posts.update_post(post, post_params) do
  #     {:ok, post} ->
  #       conn
  #       |> put_flash(:info, "Post updated successfully.")
  #       |> redirect(to: ~p"/posts/#{post}")

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       render(conn, :edit, post: post, changeset: changeset)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   post = Posts.get_post!(id)
  #   {:ok, _post} = Posts.delete_post(post)

  #   conn
  #   |> put_flash(:info, "Post deleted successfully.")
  #   |> redirect(to: ~p"/posts")
  # end

end
