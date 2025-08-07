variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud region"
  type        = string
  default     = "us-central1"
}

variable "dataform_repository_name" {
  description = "Name of the Dataform repository"
  type        = string
  default     = "dataform-demo-repo"
}

variable "service_account_name" {
  description = "Name of the service account for Dataform"
  type        = string
  default     = "dataform-sa"
}

variable "git_token" {
  description = "Name of the service account for Dataform"
  type        = string
}

variable "git_username" {
  description = "Git user name"
  type        = string
}
