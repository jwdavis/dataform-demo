terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable required APIs
resource "google_project_service" "dataform_api" {
  service = "dataform.googleapis.com"
}

resource "google_project_service" "bigquery_api" {
  service = "bigquery.googleapis.com"
}

# Create BigQuery datasets
resource "google_bigquery_dataset" "raw_data" {
  dataset_id  = "dataform_demo_raw_data"
  description = "Raw data from various sources"
  location    = "US"

  depends_on = [google_project_service.bigquery_api]
}

resource "google_bigquery_dataset" "staging" {
  dataset_id  = "dataform_demo_staging"
  description = "Staging tables for data transformation"
  location    = "US"

  depends_on = [google_project_service.bigquery_api]
}

resource "google_bigquery_dataset" "marts" {
  dataset_id  = "dataform_demo_marts"
  description = "Business intelligence mart tables"
  location    = "US"

  depends_on = [google_project_service.bigquery_api]
}

resource "google_bigquery_dataset" "dataform_demo" {
  dataset_id  = "dataform_demo"
  description = "Default dataset for Dataform demo"
  location    = "US"

  depends_on = [google_project_service.bigquery_api]
}

# Create service account for Dataform
resource "google_service_account" "dataform_sa" {
  account_id   = var.service_account_name
  display_name = "Dataform Service Account"
  description  = "Service account for Dataform workflows"
}

# Grant necessary permissions to service account
resource "google_project_iam_member" "dataform_bigquery_admin" {
  project = var.project_id
  role    = "roles/bigquery.admin"
  member  = "serviceAccount:${google_service_account.dataform_sa.email}"
}

resource "google_project_iam_member" "dataform_dataform_admin" {
  project = var.project_id
  role    = "roles/dataform.admin"
  member  = "serviceAccount:${google_service_account.dataform_sa.email}"
}

resource "google_dataform_repository" "dataform_repo" {
  provider = google-beta
  project  = var.project_id
  name     = var.dataform_repository_name
  region   = var.region

  git_remote_settings {
    url                                 = "https://github.com/${var.git_username}/dataform-demo.git"
    default_branch                      = "main"
    authentication_token_secret_version = "${google_secret_manager_secret.github_token.id}/versions/latest"
  }

  workspace_compilation_overrides {
    default_database = var.project_id
    schema_suffix    = "_dev"
  }

  depends_on = [
    google_project_service.dataform_api,
    google_secret_manager_secret.github_token
  ]
}

# Secret Manager for GitHub token (you'll need to create this manually)
resource "google_secret_manager_secret" "github_token" {
  secret_id = "github-token"
  project   = var.project_id

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "github_token" {
  secret      = google_secret_manager_secret.github_token.id
  secret_data = var.git_token
}

# BigQuery tables for sample data
# Define table schemas in a local variable
locals {
  tables = {
    orders = {
      schema = [
        {
          name = "order_id"
          type = "INTEGER"
          mode = "REQUIRED"
        },
        {
          name = "customer_id"
          type = "STRING"
          mode = "REQUIRED"
        },
        {
          name = "product_id"
          type = "STRING"
          mode = "REQUIRED"
        },
        {
          name = "order_date"
          type = "STRING"
          mode = "REQUIRED"
        },
        {
          name = "quantity"
          type = "INTEGER"
          mode = "REQUIRED"
        },
        {
          name = "unit_price"
          type = "FLOAT"
          mode = "REQUIRED"
        },
        {
          name = "status"
          type = "STRING"
          mode = "REQUIRED"
        }
      ]
    },
    customers = {
      schema = [
        {
          name = "customer_id"
          type = "STRING"
          mode = "REQUIRED"
        },
        {
          name = "customer_name"
          type = "STRING"
          mode = "REQUIRED"
        },
        {
          name = "email"
          type = "STRING"
          mode = "REQUIRED"
        },
        {
          name = "registration_date"
          type = "STRING"
          mode = "REQUIRED"
        },
        {
          name = "country"
          type = "STRING"
          mode = "REQUIRED"
        }
      ]
    },
    products = {
      schema = [
        {
          name = "product_id"
          type = "STRING"
          mode = "REQUIRED"
        },
        {
          name = "product_name"
          type = "STRING"
          mode = "REQUIRED"
        },
        {
          name = "category"
          type = "STRING"
          mode = "REQUIRED"
        },
        {
          name = "cost_price"
          type = "FLOAT"
          mode = "REQUIRED"
        },
        {
          name = "retail_price"
          type = "FLOAT"
          mode = "REQUIRED"
        }
      ]
    }
  }
}

# Create BigQuery tables using for_each
resource "google_bigquery_table" "tables" {
  for_each = local.tables

  dataset_id = google_bigquery_dataset.raw_data.dataset_id
  table_id   = each.key

  schema = jsonencode(each.value.schema)
}

locals {
  bucket_name       = var.project_id
  bucket_exists     = try(data.google_storage_bucket.existing.name, null) != null
  bucket_name_final = local.bucket_exists ? data.google_storage_bucket.existing.name : google_storage_bucket.bucket[0].name
}


# Try to get existing bucket data
data "google_storage_bucket" "existing" {
  name = local.bucket_name
}

# Create bucket only if the data source fails (bucket doesn't exist)
resource "google_storage_bucket" "bucket" {
  count    = try(data.google_storage_bucket.existing.name, null) != null ? 0 : 1
  name     = local.bucket_name
  location = "US"
}

# Upload CSV files to GCS bucket using for_each
resource "google_storage_bucket_object" "csv_files" {
  for_each = local.tables

  name   = "dataform_demo/${each.key}.csv"
  bucket = local.bucket_name_final
  source = "./${each.key}.csv"

  depends_on = [

  ]
}

# # Load data from CSV files into BigQuery tables using for_each
# resource "google_bigquery_job" "data_load" {
#   for_each = local.tables

#   job_id = "${each.key}_load_${formatdate("YYYYMMDD_hhmmss", timestamp())}"

#   load {
#     source_uris = [
#       google_storage_bucket_object.csv_files[each.key].self_link
#     ]

#     destination_table {
#       project_id = var.project_id
#       dataset_id = google_bigquery_dataset.raw_data.dataset_id
#       table_id   = google_bigquery_table.tables[each.key].table_id
#     }

#     source_format     = "CSV"
#     skip_leading_rows = 1
#     field_delimiter   = ","
#     quote             = "\""
#     write_disposition = "WRITE_TRUNCATE"
#     autodetect        = false
#   }

#   depends_on = [
#     google_bigquery_table.tables,
#     google_storage_bucket_object.csv_files
#   ]
# }
