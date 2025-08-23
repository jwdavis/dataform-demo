output "project_id" {
  description = "Google Cloud Project ID"
  value       = var.project_id
}

output "dataform_repository_name" {
  description = "Name of the created Dataform repository"
  value       = google_dataform_repository.dataform_repo.name
}

output "bigquery_datasets" {
  description = "Created BigQuery datasets"
  value = {
    raw_data = google_bigquery_dataset.raw_data.dataset_id
    staging  = google_bigquery_dataset.staging.dataset_id
    marts    = google_bigquery_dataset.marts.dataset_id
  }
}

output "service_account_email" {
  description = "Email of the created service account"
  value       = google_service_account.dataform_sa.email
}
