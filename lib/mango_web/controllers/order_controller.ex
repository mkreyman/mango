defmodule MangoWeb.OrderController do
  use MangoWeb, :controller
  alias Mango.Sales.Order

  def index(conn, _params) do
    customer = conn.assigns.current_customer
    orders = Order.list(customer)

    conn
    |> render("index.html", orders: orders)
  end

  def show(conn, %{"order_id" => order_id}) do
    customer = conn.assigns.current_customer
    order = Order.show(customer, order_id)

    case order do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(MangoWeb.ErrorView)
        |> render("404.html")

      _ ->
        conn
        |> assign(:order, order)
        |> render("show.html")
    end
  end
end
