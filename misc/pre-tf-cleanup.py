import google.auth
from google.cloud import dataform_v1beta1
from google.cloud import bigquery
import sys

def get_repository_by_display_name(client, project_id, location, display_name):
    parent = f"projects/{project_id}/locations/{location}"
    repositories = client.list_repositories(parent=parent)
    for repo in repositories:
        if repo.display_name == display_name:
            return repo
    return None

def delete_workspaces(client, repo_name):
    workspaces = client.list_workspaces(parent=repo_name)
    for workspace in workspaces:
        print(f"Deleting workspace: {workspace.name}")
        client.delete_workspace(name=workspace.name)

def delete_release_configs(client, repo_name):
    release_configs = client.list_release_configs(parent=repo_name)
    for release_config in release_configs:
        print(f"Deleting release config: {release_config.name}")
        client.delete_release_config(name=release_config.name)

def delete_workflow_configs(client, repo_name):
    workflow_configs = client.list_workflow_configs(parent=repo_name)
    for workflow_config in workflow_configs:
        print(f"Deleting workflow config: {workflow_config.name}")
        client.delete_workflow_config(name=workflow_config.name)

def delete_repository(client, repo_name):
    print(f"Deleting repository: {repo_name}")
    request = dataform_v1beta1.DeleteRepositoryRequest(
        name=repo_name,
        force=True
    )
    client.delete_repository(request=request)

def delete_bigquery_datasets(project_id):
    client = bigquery.Client(project=project_id)
    datasets = list(client.list_datasets())

    for dataset in datasets:
        dataset_id = dataset.dataset_id
        if dataset_id.startswith("dataform") and dataset_id.endswith("_dev"):
            print(f"Deleting BigQuery dataset: {dataset_id}")
            client.delete_dataset(
                dataset.dataset_id,
                delete_contents=True,  # Delete all tables in the dataset
                not_found_ok=True     # Ignore if the dataset is already deleted
            )

def main():
    # Authenticate and initialize the client
    credentials, project_id = google.auth.default()
    client = dataform_v1beta1.DataformClient(credentials=credentials)

    # Read display_name from command line arguments
    if len(sys.argv) < 2:
        print("Usage: python delete_dataform_repo.py <display_name>")
        sys.exit(1)

    display_name = sys.argv[1]

    # Replace with your values
    location = "us-central1"

    # Get the repository
    repo = get_repository_by_display_name(client, project_id, location, display_name)
    if not repo:
        print(f"Repository with display name '{display_name}' not found.")
        return

    repo_name = repo.name

    # Delete workspaces, release configs, and workspace configs
    delete_workspaces(client, repo_name)
    delete_release_configs(client, repo_name)
    delete_workflow_configs(client, repo_name)

    # Delete the repository
    delete_repository(client, repo_name)

    # Delete BigQuery datasets
    delete_bigquery_datasets(project_id)

if __name__ == "__main__":
    main()
