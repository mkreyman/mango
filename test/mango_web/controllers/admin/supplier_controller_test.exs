defmodule MangoWeb.Admin.SupplierControllerTest do
  use MangoWeb.ConnCase

  alias Mango.{Warehouse, Administration}

  @admin_attrs %{email: "admin@email.com", name: "admin name", phone: "admin phone"}

  @create_attrs %{
    contact_person: "some contact_person",
    email: "some email",
    name: "some name",
    phone: "some phone"
  }
  @update_attrs %{
    contact_person: "some updated contact_person",
    email: "some updated email",
    name: "some updated name",
    phone: "some updated phone"
  }
  @invalid_attrs %{contact_person: nil, email: nil, name: nil, phone: nil}

  def fixture(:admin) do
    {:ok, admin} = Administration.create_user(@admin_attrs)
    admin
  end

  def fixture(:supplier) do
    {:ok, supplier} = Warehouse.create_supplier(@create_attrs)
    supplier
  end

  setup %{conn: _conn} do
    admin = fixture(:admin)
    token = Phoenix.Token.sign(MangoWeb.Endpoint, "user", admin.id)
    conn = get(build_conn(), "/admin/magiclink", %{"token" => token})

    {:ok, conn: conn}
  end

  describe "index" do
    test "lists all suppliers", %{conn: conn} do
      conn = get(conn, admin_supplier_path(conn, :index))
      assert html_response(conn, 200) =~ "Suppliers"
    end
  end

  describe "new supplier" do
    test "renders form", %{conn: conn} do
      conn = get(conn, admin_supplier_path(conn, :new))
      assert html_response(conn, 200) =~ "New Supplier"
    end
  end

  describe "create supplier" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, admin_supplier_path(conn, :create), supplier: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == admin_supplier_path(conn, :show, id)

      conn = get(conn, admin_supplier_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Supplier"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, admin_supplier_path(conn, :create), supplier: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Supplier"
    end
  end

  describe "edit supplier" do
    setup [:create_supplier]

    test "renders form for editing chosen supplier", %{conn: conn, supplier: supplier} do
      conn = get(conn, admin_supplier_path(conn, :edit, supplier))
      assert html_response(conn, 200) =~ "Edit Supplier"
    end
  end

  describe "update supplier" do
    setup [:create_supplier]

    test "redirects when data is valid", %{conn: conn, supplier: supplier} do
      conn = put(conn, admin_supplier_path(conn, :update, supplier), supplier: @update_attrs)

      assert redirected_to(conn) == admin_supplier_path(conn, :show, supplier)

      conn = get(conn, admin_supplier_path(conn, :show, supplier))
      assert html_response(conn, 200) =~ "some updated contact_person"
    end

    test "renders errors when data is invalid", %{conn: conn, supplier: supplier} do
      conn = put(conn, admin_supplier_path(conn, :update, supplier), supplier: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Supplier"
    end
  end

  describe "delete supplier" do
    setup [:create_supplier]

    test "deletes chosen supplier", %{conn: conn, supplier: supplier} do
      conn = delete(conn, admin_supplier_path(conn, :delete, supplier))
      assert redirected_to(conn) == admin_supplier_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, admin_supplier_path(conn, :show, supplier))
      end)
    end
  end

  defp create_supplier(_) do
    supplier = fixture(:supplier)
    {:ok, supplier: supplier}
  end
end
