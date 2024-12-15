defmodule ExInstagram.LogsTest do
  use ExInstagram.DataCase

  alias ExInstagram.Logs

  describe "logs" do
    alias ExInstagram.Logs.Log

    import ExInstagram.LogsFixtures

    @invalid_attrs %{message: nil, event: nil, emoji: nil}

    test "list_logs/0 returns all logs" do
      log = log_fixture()
      assert Logs.list_logs() == [log]
    end

    test "get_log!/1 returns the log with given id" do
      log = log_fixture()
      assert Logs.get_log!(log.id) == log
    end

    test "create_log/1 with valid data creates a log" do
      valid_attrs = %{message: "some message", event: "some event", emoji: "some emoji"}

      assert {:ok, %Log{} = log} = Logs.create_log(valid_attrs)
      assert log.message == "some message"
      assert log.event == "some event"
      assert log.emoji == "some emoji"
    end

    test "create_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logs.create_log(@invalid_attrs)
    end

    test "update_log/2 with valid data updates the log" do
      log = log_fixture()

      update_attrs = %{
        message: "some updated message",
        event: "some updated event",
        emoji: "some updated emoji"
      }

      assert {:ok, %Log{} = log} = Logs.update_log(log, update_attrs)
      assert log.message == "some updated message"
      assert log.event == "some updated event"
      assert log.emoji == "some updated emoji"
    end

    test "update_log/2 with invalid data returns error changeset" do
      log = log_fixture()
      assert {:error, %Ecto.Changeset{}} = Logs.update_log(log, @invalid_attrs)
      assert log == Logs.get_log!(log.id)
    end

    test "delete_log/1 deletes the log" do
      log = log_fixture()
      assert {:ok, %Log{}} = Logs.delete_log(log)
      assert_raise Ecto.NoResultsError, fn -> Logs.get_log!(log.id) end
    end

    test "change_log/1 returns a log changeset" do
      log = log_fixture()
      assert %Ecto.Changeset{} = Logs.change_log(log)
    end
  end
end
