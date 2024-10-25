defmodule UsersApi.MailerTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog
  import Mox

  alias UsersApi.Mailer

  setup :verify_on_exit!

  @names ["Alice", "Bob", "Carol"]

  test "invite/1 sends emails successfully" do
    expect(MailerClientMock, :send_email, 3, fn
      "Alice" -> {:ok, :success}
      "Bob" -> {:ok, :success}
      "Carol" -> {:ok, :success}
    end)

    log =
      capture_log(fn ->
        assert Mailer.invite(@names) == []
      end)

    assert log == ""
  end

  test "send_email retries on :econnrefused error and logs the error" do
    expect(MailerClientMock, :send_email, 3, fn "Alice" -> {:error, :econnrefused} end)

    log =
      capture_log(fn ->
        assert Mailer.invite(["Alice"]) == [%{error: "Connection Error", name: "Alice"}]
      end)

    assert log =~ "Failed to send email to Alice, retrying... (1)"
    assert log =~ "Failed to send email to Alice, retrying... (2)"
    assert log =~ "Failed to send email to Alice, retrying... (3)"
    assert log =~ "Failed to send email to Alice after 3 retries"
  end

  test "run/1 handles a mix of success and failures" do
    expect(MailerClientMock, :send_email, 5, fn
      "Alice" -> {:ok, :success}
      "Bob" -> {:error, :econnrefused}
      "Carol" -> {:ok, :success}
    end)

    log =
      capture_log(fn ->
        assert Mailer.invite(@names) == [%{error: "Connection Error", name: "Bob"}]
      end)

    assert log =~ "Failed to send email to Bob, retrying... (1)"
    assert log =~ "Failed to send email to Bob after 3 retries"
  end
end
