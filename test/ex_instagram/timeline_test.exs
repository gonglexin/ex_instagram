defmodule ExInstagram.TimelineTest do
  use ExInstagram.DataCase

  alias ExInstagram.Timeline

  describe "posts" do
    alias ExInstagram.Timeline.Post

    import ExInstagram.TimelineFixtures

    @invalid_attrs %{images: nil, caption: nil}

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Timeline.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Timeline.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{images: ["option1", "option2"], caption: "some caption"}

      assert {:ok, %Post{} = post} = Timeline.create_post(valid_attrs)
      assert post.images == ["option1", "option2"]
      assert post.caption == "some caption"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{images: ["option1"], caption: "some updated caption"}

      assert {:ok, %Post{} = post} = Timeline.update_post(post, update_attrs)
      assert post.images == ["option1"]
      assert post.caption == "some updated caption"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_post(post, @invalid_attrs)
      assert post == Timeline.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Timeline.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Timeline.change_post(post)
    end
  end
end
