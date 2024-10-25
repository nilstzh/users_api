Mox.defmock(MailerClientMock, for: UsersApi.Mailer.ClientBehaviour)
Application.put_env(:be_exercise, :mailer_client, MailerClientMock)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(UsersApi.Repo, :manual)
