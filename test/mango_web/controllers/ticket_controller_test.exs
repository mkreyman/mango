defmodule MangoWeb.TicketControllerTest do
  use MangoWeb.ConnCase

  alias Mango.CRM

  @create_attrs %{message: "some message", status: "some status", subject: "some subject"}
  # @update_attrs %{message: "some updated message", status: "some updated status", subject: "some updated subject"}
  @invalid_attrs %{message: nil, status: nil, subject: nil}
  @customer_attrs %{
    "name" => "John",
    "email" => "john@example.com",
    "password" => "secret",
    "residence_area" => "Area 1",
    "phone" => "1111"
  }

  def fixture(:ticket, customer) do
    {:ok, ticket} = CRM.create_customer_ticket(customer, @create_attrs)
    ticket
  end

  setup %{conn: _conn} do
    {:ok, customer} = CRM.create_customer(@customer_attrs)
    conn = post(build_conn(), "/login", %{"session" => @customer_attrs})

    {:ok, conn: conn, current_customer: customer}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get(conn, ticket_path(conn, :index))
    assert html_response(conn, 200) =~ "Listing Tickets"
  end

  test "renders form for new tickets", %{conn: conn} do
    conn = get(conn, ticket_path(conn, :new))
    assert html_response(conn, 200) =~ "New Ticket"
  end

  test "creates ticket and redirects to show when data is valid", %{conn: conn} do
    conn = post(conn, ticket_path(conn, :create), ticket: @create_attrs)

    assert %{id: id} = redirected_params(conn)
    assert redirected_to(conn) == ticket_path(conn, :show, id)

    conn = get(conn, ticket_path(conn, :show, id))
    assert html_response(conn, 200) =~ "Show Ticket"
  end

  test "does not create ticket and renders errors when data is invalid", %{conn: conn} do
    conn = post(conn, ticket_path(conn, :create), ticket: @invalid_attrs)
    assert html_response(conn, 200) =~ "New Ticket"
  end

  # test "renders form for editing chosen ticket", %{conn: conn, current_customer: customer} do
  #   ticket = fixture(:ticket, customer)
  #   conn = get conn, ticket_path(conn, :edit, ticket)
  #   assert html_response(conn, 200) =~ "Edit Ticket"
  # end

  # test "updates chosen ticket and redirects when data is valid", %{conn: conn, current_customer: customer} do
  #   ticket = fixture(:ticket, customer)
  #   conn = put conn, ticket_path(conn, :update, ticket), ticket: @update_attrs
  #   assert redirected_to(conn) == ticket_path(conn, :show, ticket)

  #   conn = get conn, ticket_path(conn, :show, ticket)
  #   assert html_response(conn, 200) =~ "some updated message"
  # end

  # test "does not update chosen ticket and renders errors when data is invalid", %{conn: conn, current_customer: customer} do
  #   ticket = fixture(:ticket, customer)
  #   conn = put conn, ticket_path(conn, :update, ticket), ticket: @invalid_attrs
  #   assert html_response(conn, 200) =~ "Edit Ticket"
  # end

  # test "deletes chosen ticket", %{conn: conn, current_customer: customer} do
  #   ticket = fixture(:ticket, customer)
  #   conn = delete conn, ticket_path(conn, :delete, ticket)
  #   assert redirected_to(conn) == ticket_path(conn, :index)
  #   assert_error_sent 404, fn ->
  #     get conn, ticket_path(conn, :show, ticket)
  #   end
  # end
end
