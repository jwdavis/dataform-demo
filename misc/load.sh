#!/bin/bash

# Shell script to load CSV data into BigQuery tables
# Equivalent to the SQL LOAD DATA statements

# Prompt user for project ID
read -p "Enter your Google Cloud Project ID: " PROJECT_ID
if [ -z "$PROJECT_ID" ]; then
  echo "Project ID is required. Exiting."
  exit 1
fi

# Set variables
DATASET="dataform_demo_raw_data"
BUCKET="gs://${PROJECT_ID}/dataform_demo"

echo "Loading data into BigQuery tables..."

# Load customers.csv
echo "Loading customers data..."
bq load \
  --source_format=CSV \
  --skip_leading_rows=1 \
  --replace \
  ${DATASET}.customers \
  ${BUCKET}/customers.csv \
  customer_id:STRING,customer_name:STRING,email:STRING,registration_date:STRING,country:STRING

if [ $? -eq 0 ]; then
  echo "✓ Customers data loaded successfully"
else
  echo "✗ Failed to load customers data"
  exit 1
fi

# Load orders.csv
echo "Loading orders data..."
bq load \
  --source_format=CSV \
  --skip_leading_rows=1 \
  --replace \
  ${DATASET}.orders \
  ${BUCKET}/orders.csv \
  order_id:INTEGER,customer_id:STRING,product_id:STRING,order_date:STRING,quantity:INTEGER,unit_price:FLOAT,status:STRING

if [ $? -eq 0 ]; then
  echo "✓ Orders data loaded successfully"
else
  echo "✗ Failed to load orders data"
  exit 1
fi

# Load products.csv
echo "Loading products data..."
bq load \
  --source_format=CSV \
  --skip_leading_rows=1 \
  --replace \
  ${DATASET}.products \
  ${BUCKET}/products.csv \
  product_id:STRING,product_name:STRING,category:STRING,cost_price:FLOAT,retail_price:FLOAT

if [ $? -eq 0 ]; then
  echo "✓ Products data loaded successfully"
else
  echo "✗ Failed to load products data"
  exit 1
fi

echo "All data loaded successfully!"


