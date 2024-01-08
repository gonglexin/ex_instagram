defmodule ExInstagramWeb.UserLive.Index do
  use ExInstagramWeb, :live_view

  require Logger

  alias ExInstagram.Accounts
  alias ExInstagram.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :users, Accounts.list_users())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Users")
    |> assign(:user, nil)
  end

  @impl true
  def handle_info({ExInstagramWeb.UserLive.FormComponent, {:saved, user}}, socket) do
    {:noreply, stream_insert(socket, :users, user)}
  end

  def handle_info(
        {ref, %{id: id, url: avatar_url}},
        socket
      ) do
    Logger.info("Updating user #{id} with avatar url: #{avatar_url}")
    Process.demonitor(ref, [:flush])

    Accounts.get_user!(id)
    |> Accounts.update_user(%{avatar: avatar_url})

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _} = Accounts.delete_user(user)

    {:noreply, stream_delete(socket, :users, user)}
  end
end
