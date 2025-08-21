-- Load customers.csv into dataform_demo_raw_data.customers
LOAD DATA INTO `dataform_demo_raw_data.customers`
FROM FILES (
  format = 'CSV',
  uris = ['gs://<project-id>/dataform_demo/customers.csv'],
  skip_leading_rows = 1
);

-- Load orders.csv into dataform_demo_raw_data.orders
LOAD DATA INTO `dataform_demo_raw_data.orders`
FROM FILES (
  format = 'CSV',
  uris = ['gs://<project-id>/dataform_demo/orders.csv'],
  skip_leading_rows = 1
);

-- Load products.csv into dataform_demo_raw_data.products
LOAD DATA INTO `dataform_demo_raw_data.products`
FROM FILES (
  format = 'CSV',
  uris = ['gs://<project-id>/dataform_demo/products.csv'],
  skip_leading_rows = 1
);