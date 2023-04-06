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

   defp get_paper_meta(url) do
      res = Crawly.fetch(url)
      {:ok, html} = Floki.parse_document(res.body)

      title = html
      |> Floki.find(".citation__title")
      |> Floki.text

      abstract = html
      |> Floki.find(".abstractSection .abstractInFull")
      |> Floki.text

      author_names = html
      |> Floki.find(".loa__author-name")
      |> Enum.map(fn node -> Floki.text(node) end)

      %{
         "title" => title,
         "abstract" => abstract,
         "authors" => Enum.map(author_names, fn a -> %{name: a} end)
      }
   end

   def create(conn, %{"post" => post_params}) do
      paper_meta = get_paper_meta(post_params["url"])

      authors = Enum.map(paper_meta["authors"], fn author_params ->
         author = case Authors.get_author_by(author_params) do
            nil -> Authors.create_author(author_params)
            author -> {:ok, author}
         end

         elem(author, 1)
      end)

      paper_params = %{paper_meta | "authors" => authors }
      |> Map.merge(post_params)

      paper = case Papers.get_paper_by(url: post_params["url"]) do
         nil -> Papers.create_paper(paper_params)
         paper -> {:ok, paper}
      end

      post_params = %{"paper" => elem(paper, 1), "likes" => 0, "user_id" => get_session(conn, :user_id)}
      case Posts.create_post(post_params) do
         {:ok, post} ->
            conn
            |> put_flash(:info, "#{paper.title} created!")
            |> redirect(to: ~p"/")
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
