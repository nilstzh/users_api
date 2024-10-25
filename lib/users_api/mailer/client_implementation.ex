defmodule UsersApi.Mailer.ClientImplementation do
  @moduledoc """
  A module responsible for sending emails using the `BEChallengex` library.
  """

  @behaviour UsersApi.Mailer.ClientBehaviour

  @doc """
  Sends an email with the provided `name`.
  """
  @impl UsersApi.Mailer.ClientBehaviour
  def send_email(name), do: simulate_email_service(%{name: name})

  defp simulate_email_service(%{name: name}) do
    :timer.sleep(Enum.random(0..2))

    case Enum.random(1..400_000) do
      1 -> {:error, :econnrefused}
      _ -> {:ok, name}
    end
  end
end
