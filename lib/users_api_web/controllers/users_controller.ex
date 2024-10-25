defmodule UsersApiWeb.UsersController do
  use UsersApiWeb, :controller

  alias UsersApi.{Mailer, Users}

  def index(conn, params) do
    users = Users.list_users_salaries(params["name"])
    render(conn, :index, users: users)
  end

  def invite(conn, _params) do
    active_users_names = Enum.map(Users.list_active_users(), & &1.name)
    errors = Mailer.invite(active_users_names)

    render(conn, :invite, total_count: Enum.count(active_users_names), errors: errors)
  end
end
