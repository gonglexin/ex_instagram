defmodule ExInstagramWeb.UserLive.Show do
  use ExInstagramWeb, :live_view

  alias ExInstagram.{Accounts, Timeline}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    user = Accounts.get_user!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:user, user)
     |> stream(:posts, Timeline.list_posts_by_user(user))}
  end

  defp page_title(:show), do: "Show User"
  defp page_title(:edit), do: "Edit User"
end
