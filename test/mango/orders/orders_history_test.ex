defmodule Mango.OrdersHistoryTest do
  use Mango.DataCase

  alias Mango.Sales
  alias Mango.Sales.Order
  alias Mango.Catalog.Product
  alias Mango.CRM

  test "order_history/1" do
    {:ok, customer1} =
      CRM.create_customer(%{
        name: "John",
        email: "john@example.com",
        password: "secret",
        residence_area: "Area 1",
        phone: "1111"
      })

    {:ok, customer2} =
      CRM.create_customer(%{
        name: "Joanna",
        email: "joanna@example.com",
        password: "secret",
        residence_area: "Area 2",
        phone: "2222"
      })

    {:ok, product1} =
      Repo.insert(%Product{
        name: "Tomato",
        price: 55,
        sku: "A123",
        is_seasonal: false,
        category: "vegetables",
        pack_size: "1"
      })

    {:ok, product2} =
      Repo.insert(%Product{
        name: "Apple",
        price: 75,
        sku: "B232",
        is_seasonal: true,
        category: "fruits",
        pack_size: "1"
      })

    cart1 = Sales.create_cart()
    cart2 = Sales.create_cart()
    cart3 = Sales.create_cart()

    {:ok, customer1_cart1} = Sales.add_to_cart(cart1, %{product_id: product1.id, quantity: "1"})

    {:ok, customer1_cart} = Sales.add_to_cart(cart2, %{product_id: product2.id, quantity: "1"})

    {:ok, customer1_order} =
      Sales.confirm_order(customer1_cart1, %{
        customer_id: customer1.id,
        customer_name: customer1.name,
        residence_area: customer1.residence_area,
        email: customer1.email
      })

    {:ok, customer2_cart} = Sales.add_to_cart(cart3, %{product_id: product2.id, quantity: "2"})

    {:ok, customer2_order} =
      Sales.confirm_order(customer2_cart, %{
        customer_id: customer2.id,
        customer_name: customer2.name,
        residence_area: customer2.residence_area,
        email: customer2.email
      })

    orders = Order.list(customer1)
    assert Enum.member?(orders, customer1_order)
    refute Enum.member?(orders, customer1_cart)
    refute Enum.member?(orders, customer2_order)
  end
end
