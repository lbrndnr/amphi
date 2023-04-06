defmodule AmphiWeb.CommentControllerTest do
  use AmphiWeb.ConnCase

  import Amphi.CommentsFixtures

  @create_attrs %{likes: 42, text: "some text"}
  @update_attrs %{likes: 43, text: "some updated text"}
  @invalid_attrs %{likes: nil, text: nil}

  describe "index" do
    test "lists all comments", %{conn: conn} do
      conn = get(conn, ~p"/comments")
      assert html_response(conn, 200) =~ "Listing Comments"
    end
  end

  describe "new comment" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/comments/new")
      assert html_response(conn, 200) =~ "New Comment"
    end
  end

  describe "create comment" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/comments", comment: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/comments/#{id}"

      conn = get(conn, ~p"/comments/#{id}")
      assert html_response(conn, 200) =~ "Comment #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/comments", comment: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Comment"
    end
  end

  describe "edit comment" do
    setup [:create_comment]

    test "renders form for editing chosen comment", %{conn: conn, comment: comment} do
      conn = get(conn, ~p"/comments/#{comment}/edit")
      assert html_response(conn, 200) =~ "Edit Comment"
    end
  end

  describe "update comment" do
    setup [:create_comment]

    test "redirects when data is valid", %{conn: conn, comment: comment} do
      conn = put(conn, ~p"/comments/#{comment}", comment: @update_attrs)
      assert redirected_to(conn) == ~p"/comments/#{comment}"

      conn = get(conn, ~p"/comments/#{comment}")
      assert html_response(conn, 200) =~ "some updated text"
    end

    test "renders errors when data is invalid", %{conn: conn, comment: comment} do
      conn = put(conn, ~p"/comments/#{comment}", comment: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Comment"
    end
  end

  describe "delete comment" do
    setup [:create_comment]

    test "deletes chosen comment", %{conn: conn, comment: comment} do
      conn = delete(conn, ~p"/comments/#{comment}")
      assert redirected_to(conn) == ~p"/comments"

      assert_error_sent 404, fn ->
        get(conn, ~p"/comments/#{comment}")
      end
    end
  end

  defp create_comment(_) do
    comment = comment_fixture()
    %{comment: comment}
  end
end
