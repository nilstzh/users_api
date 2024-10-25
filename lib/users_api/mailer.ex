defmodule UsersApi.Mailer do
  @moduledoc """
  A module providing mailing functionality.
  """

  require Logger

  @max_retries 3

  @doc """
  Sends invintation emails to a list of `names`.
  Emails are sent concurrently with a max of 5 processes at once.

  ## Parameters

    - names: A list of names to send emails to.

  ## Example

      iex> UsersApi.Mailer.invite(["Alice", "Bob", "Carol"])
      :ok
  """
  @spec invite([String.t()]) :: :ok
  def invite(names) do
    names
    |> Task.async_stream(&send_invite_email(&1), max_concurrency: 5, timeout: 15_000)
    |> Stream.run()
  end

  @spec send_invite_email(String.t(), non_neg_integer()) :: nil
  defp send_invite_email(name, retries \\ 0)

  defp send_invite_email(name, retries) when retries < @max_retries do
    case client().send_email(name) do
      {:error, :econnrefused} ->
        Logger.error("Failed to send email to #{name}, retrying... (#{retries + 1})")
        send_invite_email(name, retries + 1)

      {:ok, _result} ->
        nil
    end
  end

  @spec send_invite_email(String.t(), non_neg_integer()) :: nil
  defp send_invite_email(name, _retries) do
    Logger.error("Failed to send email to #{name} after #{@max_retries} retries")
  end

  @spec client() :: atom()
  defp client() do
    Application.get_env(:be_exercise, :mailer_client, UsersApi.Mailer.ClientImplementation)
  end
end
