defmodule MangoWeb.Router do
  use MangoWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :frontend do
    plug(MangoWeb.Plugs.LoadCustomer)
    plug(MangoWeb.Plugs.FetchCart)
    plug(MangoWeb.Plugs.Locale)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :admin do
    plug(MangoWeb.Plugs.AdminLayout)
    plug(MangoWeb.Plugs.LoadAdmin)
  end

  scope "/", MangoWeb do
    pipe_through([:browser, :frontend])

    # Add all routes that don't require authentication
    get("/login", SessionController, :new)
    post("/login", SessionController, :create)
    get("/register", RegistrationController, :new)
    post("/register", RegistrationController, :create)

    get("/", PageController, :index)
    get("/categories/:name", CategoryController, :show)

    get("/cart", CartController, :show)
    post("/cart", CartController, :add)
    put("/cart", CartController, :update)
  end

  scope "/", MangoWeb do
    pipe_through([:browser, :frontend, MangoWeb.Plugs.AuthenticateCustomer])

    # Add all routes that do require authentication
    get("/logout", SessionController, :delete)
    get("/checkout", CheckoutController, :edit)
    put("/checkout/confirm", CheckoutController, :update)
    get("/orders", OrderController, :index)
    get("/orders/:order_id", OrderController, :show)

    resources("/tickets", TicketController, except: [:edit, :update, :delete])
  end

  scope "/admin", MangoWeb.Admin, as: :admin do
    pipe_through([:browser, :admin])

    # Routes that do not require authentication
    get("/login", SessionController, :new)
    post("/sendlink", SessionController, :send_link)
    get("/magiclink", SessionController, :create)
  end

  scope "/admin", MangoWeb.Admin, as: :admin do
    pipe_through([:browser, :admin, MangoWeb.Plugs.AuthenticateAdmin])

    # Routes that do require admin authentication
    resources("/users", UserController)
    resources("/warehouse_items", WarehouseItemController)
    resources("/suppliers", SupplierController)

    get("/orders", OrderController, :index)
    get("/orders/:order_id", OrderController, :show)

    get("/customers", CustomerController, :index)
    get("/customers/:customer_id", CustomerController, :show)

    get("/logout", SessionController, :delete)

    get("/", DashboardController, :show)
  end
end
