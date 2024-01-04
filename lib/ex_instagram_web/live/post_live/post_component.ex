defmodule ExInstagramWeb.PostLive.PostComponent do
  use ExInstagramWeb, :live_component

  def render(assigns) do
    ~H"""
    <div id={@id} class="max-w-md mx-auto border-b pb-6 border-gray-300">
      <.link navigate={~p"/users/#{@user}"} class="group block flex-shrink-0">
        <div class="flex items-center">
          <div>
            <img class="inline-block h-9 w-9 rounded-full" src={"https://placekitten.com/100/100"} alt="" />
          </div>
          <div class="ml-3">
            <p class="text-base font-semibold text-gray-900 group-hover:text-gray-700">
              <%= @user.name %>
              <span class="text-xs text-gray-500">• <%= Timex.from_now(@post.inserted_at) %></span>
            </p>
            <p class="text-xs font-medium text-gray-500"><%= "Central Plaza" %></p>
          </div>
        </div>
      </.link>
      <div class="mt-4">
        <.link navigate={~p"/p/#{@post.id}"}>
          <img class="rounded-sm" src={@post.images |> List.first() } loading="lazy" />
        </.link>
        <%!-- Reactions --%>
        <button phx-click="like" phx-value-post-id={@post.id}>
          <.icon name="hero-heart" class="h-6 w-6 mt-3 hover:text-gray-500" />
        </button>
        <button phx-click="comment" phx-value-post-id={@post.id}>
          <.icon name="hero-chat-bubble-oval-left" class="h-6 w-6 mt-3 hover:text-gray-500" />
        </button>

        <%!-- Caption --%>
        <p :if={not is_nil(@post.caption)} class="text-base mt-2">
          <.link class="font-bold" navigate={~p"/#{@user.name}"}>
            <%= @user.name %>
          </.link>
          <%= @post.caption |> String.replace("\"", "") %>
        </p>
      </div>
    </div>
    """
    # ~H"""
    # <div id={@id} class="max-w-md mx-auto border-b pb-6 border-gray-300">
    #   <div class="flex items-center">
    #     <div>
    #       <img class="" src={@post.images |> List.first()}/>
    #     </div>
    #     <p><%= @post.caption %></p>
    #   </div>
    # </div>
    # """
    # ~H"""
    # <div id={"post-component-#{@id}"} class="max-w-md mx-auto border-b pb-6 border-gray-300">
    #   <.link navigate={~p"/users/#{@user}"} class="group block flex-shrink-0">
    #     <div class="flex items-center">
    #       <div>
    #         <img class="inline-block h-9 w-9 rounded-full" src={nil} alt="" />
    #       </div>
    #       <div class="ml-3">
    #         <p class="text-base font-semibold text-gray-900 group-hover:text-gray-700">
    #           <%= @user.name %>
    #           <span class="text-xs text-gray-500">• <%= Timex.from_now(@post.inserted_at) %></span>
    #         </p>
    #         <p class="text-xs font-medium text-gray-500"><%= "Center Plaza" %></p>
    #       </div>
    #     </div>
    #   </.link>
    # </div>
    # """
  end
end
