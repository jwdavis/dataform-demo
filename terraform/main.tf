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
  dataset_id  = "dataform_raw_data"
  description = "Raw data from various sources"
  location    = "US"

  depends_on = [google_project_service.bigquery_api]
}

resource "google_bigquery_dataset" "staging" {
  dataset_id  = "dataform_staging"
  description = "Staging tables for data transformation"
  location    = "US"

  depends_on = [google_project_service.bigquery_api]
}

resource "google_bigquery_dataset" "marts" {
  dataset_id  = "dataform_marts"
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
resource "google_bigquery_table" "orders" {
  dataset_id = google_bigquery_dataset.raw_data.dataset_id
  table_id   = "orders"

  schema = jsonencode([
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
  ])
}

resource "google_bigquery_table" "customers" {
  dataset_id = google_bigquery_dataset.raw_data.dataset_id
  table_id   = "customers"

  schema = jsonencode([
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
  ])
}

resource "google_bigquery_table" "products" {
  dataset_id = google_bigquery_dataset.raw_data.dataset_id
  table_id   = "products"

  schema = jsonencode([
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
  ])
}
