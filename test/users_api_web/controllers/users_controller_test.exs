defmodule UsersApiWeb.UsersControllerTest do
  use UsersApiWeb.ConnCase, async: true

  import UsersApi.SetupHelpers
  import ExUnit.CaptureLog
  import Mox

  setup [:prepare_users]

  describe "GET /users" do
    test "GET /users", %{conn: conn} do
      conn = get(conn, ~p"/api/users")

      assert json_response(conn, 200) == [
               %{
                 "name" => "John",
                 "salary" => %{"amount" => 2000, "currency" => "EUR", "state" => "active"}
               },
               %{
                 "name" => "Satomi",
                 "salary" => %{"amount" => 2000, "currency" => "EUR", "state" => "inactive"}
               },
               %{
                 "name" => "Tom",
                 "salary" => %{"amount" => 2000, "currency" => "EUR", "state" => "active"}
               }
             ]
    end

    test "GET /users with matching `name` param", %{conn: conn} do
      conn = get(conn, ~p"/api/users?name=Tom")

      assert json_response(conn, 200) == [
               %{
                 "name" => "Satomi",
                 "salary" => %{"amount" => 2000, "currency" => "EUR", "state" => "inactive"}
               },
               %{
                 "name" => "Tom",
                 "salary" => %{"amount" => 2000, "currency" => "EUR", "state" => "active"}
               }
             ]
    end

    test "GET /users with non-matching `name` param", %{conn: conn} do
      conn = get(conn, ~p"/api/users?name=NoSuchName")
      assert json_response(conn, 200) == []
    end

    test "GET /users with unknown param", %{conn: conn} do
      conn = get(conn, ~p"/api/users?unknown=Tom")

      assert json_response(conn, 200) == [
               %{
                 "name" => "John",
                 "salary" => %{"amount" => 2000, "currency" => "EUR", "state" => "active"}
               },
               %{
                 "name" => "Satomi",
                 "salary" => %{"amount" => 2000, "currency" => "EUR", "state" => "inactive"}
               },
               %{
                 "name" => "Tom",
                 "salary" => %{"amount" => 2000, "currency" => "EUR", "state" => "active"}
               }
             ]
    end
  end

  describe "POST /invite-users" do
    setup :verify_on_exit!

    test "POST /invite-users success", %{conn: conn} do
      expect(MailerClientMock, :send_email, 2, fn
        "John" -> {:ok, :success}
        "Tom" -> {:ok, :success}
      end)

      conn = post(conn, ~p"/api/invite-users")

      assert json_response(conn, 200) == %{
               "errors" => [],
               "status" => "success",
               "succesfully_sent" => 2
             }
    end

    test "POST /invite-users error", %{conn: conn} do
      expect(MailerClientMock, :send_email, 4, fn
        "John" -> {:error, :econnrefused}
        "Tom" -> {:ok, :success}
      end)

      log =
        capture_log(fn ->
          conn = post(conn, ~p"/api/invite-users")

          assert json_response(conn, 200) == %{
                   "errors" => [%{"error" => "Connection Error", "name" => "John"}],
                   "status" => "success",
                   "succesfully_sent" => 1
                 }
        end)

      assert log =~ "Failed to send email to John, retrying... (1)"
      assert log =~ "Failed to send email to John, retrying... (2)"
      assert log =~ "Failed to send email to John, retrying... (3)"
      assert log =~ "Failed to send email to John after 3 retries"
    end
  end
end
