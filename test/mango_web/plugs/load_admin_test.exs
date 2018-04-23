defmodule MangoWeb.Plugs.LoadAdminTest do
  use MangoWeb.ConnCase
  alias Mango.Administration

  @valid_attrs %{
    "name" => "John",
    "email" => "john@example.com",
    "password" => "secret",
    "phone" => "1111"
  }

  test "fetch admin user from session" do
    # Create a new customer
    {:ok, user} = Administration.create_user(@valid_attrs)

    # Generate a token for the user
    token = Phoenix.Token.sign(MangoWeb.Endpoint, "user", user.id)

    # Build a new conn by posting login data to "/session" path
    conn = get(build_conn(), "/admin/magiclink", %{"token" => token})

    # We reuse the same conn now instead of building a new one
    conn = get(conn, "/admin/users")

    # now we expect the conn to have the `:current_customer` data loaded in conn.
    assert user.id == conn.assigns.current_admin.id
  end
end
