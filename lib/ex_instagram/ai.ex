defmodule ExInstagram.Ai do
  use GenServer, restart: :transient
  require Logger

  alias ExInstagram.{Timeline, Bard, Replicate, Accounts}

  # how fast our agent thinks
  @cycle_time 1000
  @actions_probabilities [post: 0.7, look: 0.2, sleep: 0.1]

  def start_link(user) do
    GenServer.start_link(__MODULE__, user, name: {:global, Accounts.pid_name(user)})
  end

  @impl true
  def init(user) do
    Phoenix.PubSub.broadcast(ExInstagram.PubSub, "users_pids", {:users_pids, :updated})
    broadcast({:thought, "🛌", "I'm waking up!"}, user)
    Process.send_after(self(), :think, 3000)
    {:ok, user}
  end

  @impl true
  def handle_info(:think, user) do
    action = get_action()
    broadcast({:thought, "💭", "I want to #{action}"}, user)
    Process.send_after(self(), action, Enum.random([1000, 2000, 5000, 10000]))
    {:noreply, user}
  end

  def handle_info(:post, user) do
    if can_post_again?(user) do
      with {:ok, caption} <- Bard.gen_caption(user.vibe, user.language),
           {:ok, image_url} <- Replicate.gen_image(caption),
           {:ok, _post} <- create_post(user, caption, image_url) do
        next_move()
        {:noreply, user}
      end
    else
      broadcast({:thought, "🚫", "I can't post, posted too recently!"}, user)
      next_move()
      {:noreply, user}
    end
  end

  def handle_info(:look, user) do
    broadcast({:thought, "🤳", "I'm scrolling at the feed"}, user)
    next_move()
    {:noreply, user}
  end

  def handle_info(:sleep, user) do
    broadcast({:action, "💤", "I'm going back to sleep..."}, user)
    {:stop, :normal, user}
  end

  def broadcast({event, emoji, msg}, user) do
    Logger.info("#{inspect(self())} #{emoji} #{user.name} - #{msg}")

    log =
      ExInstagram.Logs.create_log!(%{
        event: event |> Atom.to_string(),
        message: msg,
        user_id: user.id,
        emoji: emoji
      })

    Phoenix.PubSub.broadcast(ExInstagram.PubSub, "feed", {"user_activity", event, log})
  end

  defp get_action do
    @actions_probabilities
    |> Enum.flat_map(fn {action, probability} ->
      List.duplicate(action, Float.round(probability * 100) |> trunc())
    end)
    |> Enum.random()
  end

  defp next_move, do: Process.send_after(self(), :think, @cycle_time)

  defp create_post(user, caption, image_url) do
    {:ok, post} =
      user
      |> Timeline.create_post(%{
        images: [image_url],
        caption: caption
      })

    broadcast(
      {:new_post, "🖼️", "I'm posting the post:#{post.id}! I hope it goes well!"},
      user
    )

    {:ok, post}
  end

  defp can_post_again?(user) do
    is_new_user?(user) || is_posted_long_time_ago?(user)
  end

  defp is_new_user?(user) do
    NaiveDateTime.diff(NaiveDateTime.utc_now(), user.inserted_at, :minute) < 20
  end

  defp is_posted_long_time_ago?(user) do
    case Timeline.list_posts_by_user(user, 1) do
      [] ->
        true

      [last_post] ->
        NaiveDateTime.diff(NaiveDateTime.utc_now(), last_post.inserted_at, :minute) >= 5
    end
  end
end
