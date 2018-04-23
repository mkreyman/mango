defmodule MangoWeb.Admin.UserControllerTest do
  use MangoWeb.ConnCase

  alias Mango.Administration

  @admin_attrs %{email: "admin email", name: "admin name", phone: "admin phone"}
  @create_attrs %{email: "some email", name: "some name", phone: "some phone"}
  @update_attrs %{
    email: "some updated email",
    name: "some updated name",
    phone: "some updated phone"
  }
  @invalid_attrs %{email: nil, name: nil, phone: nil}

  def fixture(:user) do
    {:ok, user} = Administration.create_user(@create_attrs)
    user
  end

  def fixture(:admin) do
    {:ok, admin} = Administration.create_user(@admin_attrs)
    admin
  end

  describe "unathenticated requests get redirected" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, admin_user_path(conn, :index))
      assert html_response(conn, 302) =~ "redirected"
    end
  end

  describe "index with authenticated admin" do
    setup [:authenticate_admin]

    test "lists all users", %{conn: conn} do
      conn = get(conn, admin_user_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Users"
    end
  end

  describe "new user" do
    setup [:authenticate_admin]

    test "renders form", %{conn: conn} do
      conn = get(conn, admin_user_path(conn, :new))
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    setup [:authenticate_admin]

    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, admin_user_path(conn, :create), user: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == admin_user_path(conn, :show, id)

      conn = get(conn, admin_user_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show User"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, admin_user_path(conn, :create), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "edit user" do
    setup [:create_user, :authenticate_admin]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, admin_user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user, :authenticate_admin]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = put(conn, admin_user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == admin_user_path(conn, :show, user)

      conn = get(conn, admin_user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "some updated email"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, admin_user_path(conn, :update, user), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "delete user" do
    setup [:create_user, :authenticate_admin]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, admin_user_path(conn, :delete, user))
      assert redirected_to(conn) == admin_user_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, admin_user_path(conn, :show, user))
      end)
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end

  defp authenticate_admin(_) do
    admin = fixture(:admin)
    token = Phoenix.Token.sign(MangoWeb.Endpoint, "user", admin.id)
    conn = get(build_conn(), "/admin/magiclink", %{"token" => token})
    {:ok, conn: conn}
  end
end
