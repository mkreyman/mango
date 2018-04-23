defmodule MangoWeb.Admin.CustomerController do
  use MangoWeb, :controller

  alias Mango.CRM.Customer
  alias Mango.Repo

  def index(conn, _params) do
    customers = Customer |> Repo.all()

    conn
    |> put_layout("admin_app.html")
    |> render("index.html", customers: customers)
  end

  def show(conn, %{"customer_id" => customer_id}) do
    customer = Customer |> Repo.get(customer_id)
    render(conn, "show.html", customer: customer)
  end
end
