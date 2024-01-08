defmodule ExInstagramWeb.PostLive.Index do
  use ExInstagramWeb, :live_view

  alias ExInstagram.{Accounts, Logs, Timeline, Ai, AiSupervisor}
  alias ExInstagram.Timeline.Post

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(ExInstagram.PubSub, "feed")
      Phoenix.PubSub.subscribe(ExInstagram.PubSub, "users_pids")
      Timeline.subscribe()
    end

    socket =
      socket
      |> assign(:users_pids, Accounts.get_users_pids())
      |> stream(:posts, Timeline.list_recent_posts(100))
      |> stream(:logs, Logs.list_recent_logs(10))

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, Timeline.get_post!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
  end

  @impl true
  def handle_info({:users_pids, :updated}, socket) do
    users_pids = Accounts.get_users_pids()
    {:noreply, socket |> assign(:users_pids, users_pids)}
  end

  @impl true
  def handle_info({:post_created, post}, socket) do
    {:noreply, socket |> stream_insert(:posts, post, at: 0)}
  end

  @impl true
  def handle_info({ExInstagramWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    {:noreply, stream_insert(socket, :posts, post)}
  end

  @impl true
  def handle_info({"user_activity", _event, log}, socket) do
    {:noreply, socket |> stream_insert(:logs, log, at: 0)}
  end

  @impl true
  def handle_event("wake-up", _, socket) do
    Accounts.list_users()
    |> Enum.each(&AiSupervisor.start_child(&1))

    {:noreply, socket}
  end

  @impl true
  def handle_event("sleep", _, socket) do
    DynamicSupervisor.which_children(AiSupervisor)
    |> Enum.each(fn {_, pid, :worker, [Ai]} ->
      DynamicSupervisor.terminate_child(AiSupervisor, pid)
    end)

    Phoenix.PubSub.broadcast(ExInstagram.PubSub, "users_pids", {:users_pids, :updated})

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Timeline.get_post!(id)
    {:ok, _} = Timeline.delete_post(post)

    {:noreply, stream_delete(socket, :posts, post)}
  end
end
