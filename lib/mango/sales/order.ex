defmodule Mango.Sales.Order do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mango.Sales.{Order, LineItem}
  alias Mango.Repo

  schema "orders" do
    embeds_many(:line_items, LineItem, on_replace: :delete)
    field(:status, :string)
    field(:total, :decimal)
    field(:comments, :string)
    field(:customer_id, :integer)
    field(:customer_name, :string)
    field(:email, :string)
    field(:residence_area, :string)
    # belongs_to(:customer, Mango.CRM.Customer)

    timestamps()
  end

  @doc false
  def changeset(%Order{} = order, attrs) do
    order
    |> cast(attrs, [:status, :total])
    |> cast_embed(:line_items, required: true, with: &LineItem.changeset/2)
    |> set_order_total
    |> validate_required([:status, :total])
  end

  defp set_order_total(changeset) do
    items = get_field(changeset, :line_items)

    total =
      Enum.reduce(items, Decimal.new(0), fn item, acc ->
        Decimal.add(acc, item.total)
      end)

    changeset
    |> put_change(:total, total)
  end

  def checkout_changeset(%Order{} = order, attrs) do
    attrs =
      attrs
      |> Map.put(:comments, attrs["comments"])
      |> Map.drop(["comments"])

    changeset(order, attrs)
    |> cast(attrs, [:customer_id, :customer_name, :residence_area, :email, :comments])
    |> validate_required([:customer_id, :customer_name, :residence_area, :email])
  end

  def list(customer) do
    scope(customer)
    |> Repo.all()
  end

  def show(customer, order_id) do
    scope(customer)
    |> Repo.get(order_id)
  end

  defp scope(customer) do
    from(o in Order, where: o.customer_id == ^customer.id and o.status == "Confirmed")
  end
end
