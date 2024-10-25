defmodule UsersApiWeb.UsersController do
  @moduledoc """
  Controller for managing user-related actions, such as listing users and sending invitations.

  This module defines actions for:
    - `index/2`: Lists users based on a name filter.
    - `invite/2`: Sends an invitation to active users.
  """

  use UsersApiWeb, :controller

  alias UsersApi.{Mailer, Users}

  @doc """
  Lists users, filtering them based on the provided name parameter.

  ## Example

      GET /api/users?name=John
  """
  def index(conn, params) do
    users = Users.list_users_salaries(params["name"])

    render(conn, :index, users: users)
  end

  @doc """
  Invites users with active salaries via email.

  ## Example

      GET /api/invite-users
  """
  def invite(conn, _params) do
    active_users_names = Enum.map(Users.list_active_users(), & &1.name)
    errors = Mailer.invite(active_users_names)

    render(conn, :invite, total_count: Enum.count(active_users_names), errors: errors)
  end
end
