defmodule UsersApiWeb.UsersController do
  use UsersApiWeb, :controller

  alias UsersApi.Users

  def index(conn, params) do
    users = Users.list_users_salaries(params["name"])
    render(conn, :index, users: users)
  end
end
