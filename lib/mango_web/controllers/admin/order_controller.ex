defmodule MangoWeb.Admin.OrderController do
  use MangoWeb, :controller
  import Ecto.Query

  alias Mango.Sales.Order
  alias Mango.Repo

  def index(conn, _params) do
    orders =
      from(o in Order, where: o.status == "Confirmed")
      |> Repo.all()

    conn
    |> put_layout("admin_app.html")
    |> render("index.html", orders: orders)
  end

  def show(conn, %{"order_id" => order_id}) do
    order = Order |> Repo.get(order_id)
    render(conn, "show.html", order: order)
  end
end
