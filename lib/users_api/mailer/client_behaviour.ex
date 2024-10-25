defmodule UsersApi.Mailer.ClientBehaviour do
  @callback send_email(String.t()) :: {:ok, String.t()} | {:error, atom()}
end
