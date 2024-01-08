defmodule ExInstagramWeb.UserLive.Show do
  use ExInstagramWeb, :live_view

  require Logger

  alias ExInstagram.{Accounts, Timeline, Logs}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Timeline.subscribe()
      Phoenix.PubSub.subscribe(ExInstagram.PubSub, "feed")
      Phoenix.PubSub.subscribe(ExInstagram.PubSub, "users_pids")
    end

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    user = Accounts.get_user!(id)

    pid =
      case :global.whereis_name(Accounts.pid_name(user)) do
        :undefined -> nil
        pid -> pid
      end

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:user, user)
     |> assign(:pid, pid)
     |> assign(:users_pids, Accounts.get_users_pids())
     |> stream(:posts, Timeline.list_posts_by_user(user))
     |> stream(:logs, Logs.list_logs_by_user(user))}
  end

  @impl true
  def handle_event("wake-up", _, %{assigns: %{user: user}} = socket) do
    pid =
      case ExInstagram.AiSupervisor.start_child(user) do
        {:ok, pid} -> pid
        {:error, {:already_started, pid}} -> pid
      end

    socket =
      socket
      |> assign(:pid, pid)

    Phoenix.PubSub.broadcast(ExInstagram.PubSub, "users_pids", {:users_pids, :updated})

    {:noreply, socket}
  end

  @impl true
  def handle_event("sleep", _, socket) do
    pid = socket.assigns.pid

    if pid do
      Logger.info("Trying to kill #{inspect(pid)} for user: #{socket.assigns.user.name}")
      DynamicSupervisor.terminate_child(ExInstagram.AiSupervisor, pid)
    end

    Phoenix.PubSub.broadcast(ExInstagram.PubSub, "users_pids", {:users_pids, :updated})

    {:noreply, socket |> assign(pid: nil)}
  end

  @impl true
  def handle_info({:users_pids, :updated}, socket) do
    users_pids = Accounts.get_users_pids()
    Logger.info("Updating users_pids: #{inspect(users_pids)}")
    {:noreply, socket |> assign(:users_pids, users_pids)}
  end

  @impl true
  def handle_info({:post_created, post}, socket) do
    if post.user.id == socket.assigns.user.id do
      {:noreply, socket |> stream_insert(:posts, post, at: 0)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({"user_activity", _event, log}, socket) do
    if log.user_id == socket.assigns.user.id do
      {:noreply, socket |> stream_insert(:logs, log, at: 0)}
    else
      {:noreply, socket}
    end
  end

  defp page_title(:show), do: "Show User"
  defp page_title(:edit), do: "Edit User"
end
