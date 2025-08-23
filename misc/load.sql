-- Load customers.csv into dataform_demo_raw_data.customers
LOAD DATA INTO `dataform_demo_raw_data.customers`(
  customer_id STRING NOT NULL,
  customer_name STRING NOT NULL,
  email STRING NOT NULL,
  registration_date STRING NOT NULL,
  country STRING NOT NULL
)
FROM FILES (
  format = 'CSV',
  uris = ['gs://<project-id>/dataform_demo/customers.csv'],
  skip_leading_rows = 1
);

-- Load orders.csv into dataform_demo_raw_data.orders
LOAD DATA INTO `dataform_demo_raw_data.orders` (
  order_id INTEGER NOT NULL,
  customer_id STRING NOT NULL,
  product_id STRING NOT NULL,
  order_date STRING NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price FLOAT64 NOT NULL,
  status STRING NOT NULL
)
FROM FILES (
  format = 'CSV',
  uris = ['gs://<project-id>/dataform_demo/orders.csv'],
  skip_leading_rows = 1
);

-- Load products.csv into dataform_demo_raw_data.products
LOAD DATA INTO `dataform_demo_raw_data.products`(
  product_id STRING NOT NULL,
  product_name STRING NOT NULL,
  category STRING NOT NULL,
  cost_price FLOAT64 NOT NULL,
  retail_price FLOAT64 NOT NULL
)
FROM FILES (
  format = 'CSV',
  uris = ['gs://<project-id>/dataform_demo/products.csv'],
  skip_leading_rows = 1
);