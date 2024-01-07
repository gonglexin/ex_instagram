defmodule ExInstagramWeb.UserLive.Show do
  use ExInstagramWeb, :live_view

  alias ExInstagram.{Accounts, Timeline, Logs}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Timeline.subscribe()
      Phoenix.PubSub.subscribe(ExInstagram.PubSub, "feed")
    end

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    user = Accounts.get_user!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:user, user)
     |> stream(:posts, Timeline.list_posts_by_user(user))
     |> stream(:logs, Logs.list_logs_by_user(user))}
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
