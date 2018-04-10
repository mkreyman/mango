defmodule MangoWeb.Acceptance.OrdersHistoryTest do
  use Mango.DataCase
  use Hound.Helpers

  alias Mango.CRM.Customer

  hound_session()

  setup do
    ## GIVEN ##
    # There are two registered customers that 
    # placed orders for two separate products in catalog
    alias Mango.{Repo, Sales}
    alias Mango.Catalog.Product
    alias Mango.CRM

    john = %{
      name: "John",
      email: "john@example.com",
      password: "secret",
      residence_area: "Area 1",
      phone: "1111"
    }

    apples = %Product{name: "Apple", price: 100, is_seasonal: true, pack_size: "1 kg"}

    with {:ok, product} <-
           Repo.insert(apples),
         {:ok, customer} <- CRM.create_customer(john),
         {:ok, customer_cart} <-
           Sales.create_cart()
           |> Sales.add_to_cart(%{product_id: product.id, quantity: "1"}) do
      customer_cart
      |> Sales.confirm_order(%{
        customer_id: customer.id,
        customer_name: customer.name,
        residence_area: customer.residence_area,
        email: customer.email
      })
    end

    joanna = %{
      name: "Joanna",
      email: "joanna@example.com",
      password: "secret",
      residence_area: "Area 2",
      phone: "2222"
    }

    bananas = %Product{name: "Bananas", price: 10, is_seasonal: true, pack_size: "2 kg"}

    with {:ok, product} <-
           Repo.insert(bananas),
         {:ok, customer} <- CRM.create_customer(joanna),
         {:ok, customer_cart} <-
           Sales.create_cart()
           |> Sales.add_to_cart(%{product_id: product.id, quantity: "1"}) do
      customer_cart
      |> Sales.confirm_order(%{
        customer_id: customer.id,
        customer_name: customer.name,
        residence_area: customer.residence_area,
        email: customer.email
      })
    end

    :ok
  end

  test "authenticated customer can view his order history" do
    ## WHEN ##
    # the customer logs in
    customer = Repo.get_by(Customer, email: "john@example.com") |> Repo.preload(:orders)
    customer_order = customer.orders |> List.first()

    navigate_to("/login")

    form = find_element(:id, "session-form")

    find_within_element(form, :name, "session[email]")
    |> fill_field("john@example.com")

    find_within_element(form, :name, "session[password]")
    |> fill_field("secret")

    find_within_element(form, :tag, "button")
    |> click

    # and then navigates to orders page
    navigate_to("/orders")

    ## THEN ##
    # he expects the page to contain his orders history
    page_title = find_element(:css, ".page-title") |> visible_text()
    assert page_title == "Order History"

    # And I expect order details displayed
    order = find_element(:css, ".order")
    # order = find_element(:tag, "table")
    order_id = find_within_element(order, :css, ".order-id") |> visible_text()
    order_status = find_within_element(order, :css, ".order-status") |> visible_text()
    order_items = find_within_element(order, :css, ".order-items") |> visible_text()
    order_total = find_within_element(order, :css, ".order-total") |> visible_text()

    assert order_id == customer_order.id |> to_string
    assert order_status == customer_order.status

    assert order_items ==
             customer_order.line_items
             |> Enum.map(fn item -> item.product_name end)
             |> Enum.join(", ")

    assert order_total == customer_order.total |> to_string
  end

  test "authenticated customer can view a particular order" do
    ## WHEN ##
    # the customer logs in
    customer = Repo.get_by(Customer, email: "john@example.com") |> Repo.preload(:orders)
    customer_order = customer.orders |> List.first()

    navigate_to("/login")

    form = find_element(:id, "session-form")

    find_within_element(form, :name, "session[email]")
    |> fill_field("john@example.com")

    find_within_element(form, :name, "session[password]")
    |> fill_field("secret")

    find_within_element(form, :tag, "button")
    |> click

    # and then navigates to a particular order
    navigate_to("/orders/#{customer_order.id}")

    ## THEN ##
    # he expects the page to contain the order details
    assert page_source() =~ "Apple"

    order = find_element(:css, ".order")
    # order = find_element(:tag, "table")
    order_id = find_within_element(order, :css, ".order-id") |> visible_text()
    order_status = find_within_element(order, :css, ".order-status") |> visible_text()
    order_items = find_within_element(order, :css, ".order-items") |> visible_text()
    order_total = find_within_element(order, :css, ".order-total") |> visible_text()

    assert order_id == customer_order.id |> to_string
    assert order_status == customer_order.status

    assert order_items ==
             customer_order.line_items
             |> Enum.map(fn item -> item.product_name end)
             |> Enum.join(", ")

    assert order_total == customer_order.total |> to_string
  end

  test "unauthenticated user gets redirected to login page" do
    ## WHEN ##
    # unauthenticated user goes to orders page
    navigate_to("/orders")

    ## THEN ##
    # he's expected to be redirected to login page
    assert current_path() == "/login"
    message = find_element(:class, "alert-info") |> visible_text()
    assert message == "You must be signed in"
  end

  test "customers can't view other customers' orders" do
    ## WHEN ##
    # the customer logs in
    navigate_to("/login")

    form = find_element(:id, "session-form")

    find_within_element(form, :name, "session[email]")
    |> fill_field("john@example.com")

    find_within_element(form, :name, "session[password]")
    |> fill_field("secret")

    find_within_element(form, :tag, "button")
    |> click

    # and then tries to navigate to another customer's order
    another_customer = Repo.get_by(Customer, email: "joanna@example.com") |> Repo.preload(:orders)
    another_customer_order = another_customer.orders |> List.first()
    navigate_to("/orders/#{another_customer_order.id}")

    ## THEN ##
    # he is expected to see 404 "Not Found" instead
    assert page_source() =~ "Not Found"
  end
end
