-- =============================================================================
-- E-Commerce Customer & Sales Analytics — Schema
-- Engine tested against: SQLite 3 (ships as data/ecommerce.db, zero setup)
-- Portable to PostgreSQL with the two swaps noted inline below.
-- =============================================================================

CREATE TABLE IF NOT EXISTS customers (
    customer_id         INTEGER PRIMARY KEY,   -- Postgres: SERIAL / GENERATED ALWAYS AS IDENTITY
    first_name          TEXT NOT NULL,
    last_name           TEXT NOT NULL,
    email               TEXT NOT NULL,
    city                TEXT,
    state               TEXT,
    country             TEXT,
    region              TEXT,                  -- Northeast / Midwest / South / West / International
    acquisition_channel TEXT NOT NULL,          -- Organic Search / Paid Social / Direct / Email Marketing / Referral
    first_order_date    DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS products (
    product_id   INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category     TEXT NOT NULL,
    list_price   NUMERIC(10,2) NOT NULL,
    unit_cost    NUMERIC(10,2) NOT NULL         -- COGS; margin = (revenue - cost) / revenue
);

CREATE TABLE IF NOT EXISTS orders (
    order_id                INTEGER PRIMARY KEY,
    customer_id             INTEGER NOT NULL REFERENCES customers(customer_id),
    order_date              DATE NOT NULL,
    shipping_method         TEXT NOT NULL,      -- Standard / Express / Same-Day
    shipping_cost           NUMERIC(6,2) NOT NULL,
    promised_delivery_days  INTEGER NOT NULL,
    actual_delivery_days    INTEGER NOT NULL,
    delivery_date           DATE NOT NULL,
    discount_pct            NUMERIC(4,2) NOT NULL DEFAULT 0  -- order-level discount, 0.00-0.40
);

CREATE TABLE IF NOT EXISTS order_items (
    order_item_id       INTEGER PRIMARY KEY,
    order_id             INTEGER NOT NULL REFERENCES orders(order_id),
    product_id           INTEGER NOT NULL REFERENCES products(product_id),
    quantity              INTEGER NOT NULL,
    unit_price            NUMERIC(10,2) NOT NULL,   -- list price at time of order
    line_subtotal         NUMERIC(10,2) NOT NULL,   -- quantity * unit_price
    line_discount_amount  NUMERIC(10,2) NOT NULL,
    line_net_revenue      NUMERIC(10,2) NOT NULL,   -- subtotal - discount  (the revenue figure to use everywhere)
    line_cost             NUMERIC(10,2) NOT NULL,   -- quantity * unit_cost
    line_profit           NUMERIC(10,2) NOT NULL    -- net_revenue - cost
);

CREATE TABLE IF NOT EXISTS returns (
    return_id      INTEGER PRIMARY KEY,
    order_item_id  INTEGER NOT NULL REFERENCES order_items(order_item_id),
    return_date    DATE NOT NULL,
    return_reason  TEXT NOT NULL,   -- Wrong size/fit, Changed mind, Defective/damaged, Not as described
    refund_amount  NUMERIC(10,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS marketing_spend (
    channel  TEXT NOT NULL,     -- matches customers.acquisition_channel (Direct has no row: unpaid)
    month    DATE NOT NULL,     -- first day of month
    spend    NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (channel, month)
);

CREATE INDEX IF NOT EXISTS idx_orders_customer   ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_date       ON orders(order_date);
CREATE INDEX IF NOT EXISTS idx_items_order       ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_items_product     ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_returns_item      ON returns(order_item_id);

-- Postgres portability notes:
--   1. INTEGER PRIMARY KEY -> replace with GENERATED ALWAYS AS IDENTITY if you want the DB to
--      assign ids; this project loads pre-generated ids from CSV, so plain INTEGER PK is enough.
--   2. Date-part functions used in the analysis queries (strftime in SQLite) become
--      DATE_TRUNC / EXTRACT / TO_CHAR in Postgres — each query below notes the swap.
