# Dataform demo

# Introduction 

This is a simple demo of using Dataform to manage data workflows in BigQuery. It highlights how to define datasets, transform data, and manage dependencies using SQL-based configurations. The demo also integrates with GitHub for version control and uses Terraform for infrastructure setup.

## Setup instructions

1. Create a Personal Access Token in your Github account. This is required to wire the Dataform repository to your Github repository
   1. **https://github.com/settings/apps > Tokens (classic) > Generate new token**
   2. Give it **repo** permissions
   3. Copy the token and store it in an editor or file somewhere; you'll sub it into the file below
2. Fork this repository
3. Clone the forked repository into your home directory in Cloud Shell
4. Replace all occurrences of **`<project-id>`** with your project's ID
   1. Edit files
   2. Commit changes
   3. Push to your Github repo
5. In the **`misc/terraform`** directory, create a `terraform.tfvars` file
   1. Populate it like so (replacing placeholders)
    ```
    project_id               = "<project-id>"
    region                   = "us-central1"
    dataform_repository_name = "dataform-demo-repo"
    service_account_name     = "dataform-demo-sa"
    git_token                = "<github-token>"
    git_username             = "<github-handle>"
    ```
6. Run Terraform to set up all the key pieces for the demo
   ```bash
   cd ~/dataform-demo/misc/terraform
   terraform init
   terraform apply
   ```

## Demo instructions

1. Walk the students through the Github repo explaining
   1. The **`constants.js`** include (and what it will be used for)
   2. The table declarations for the raw tables (and how they work)
   3. The **staging** **`sqlx`** files
      1. What they will output
      2. How they work
   4. The **marts** **`sqlx`** files
      1. What they will output
      2. How they work
2. Show the students the data files to be imported
   1. Objects are in GCS @ **`gs://project-id/dataform-demo/`**
   2. Show contents of files
3. Show the students the datasets created
4. Show the students the Dataform repo
   1. Show the **Git connection**
   2. Show the **Service account to be used**
   3. Show the **repository setup**
   4. You can discuss the git token in Secret Manager or not
5. Create a development workspace
   1. Show the students that the code has been replicated from Github
   2. Discuss the purpose of development environments
6. Load data into the raw tables using the SQL script or shell script
   1. https://github.com/jwdavis/dataform-demo/blob/main/misc/load.sql 
   2. https://github.com/jwdavis/dataform-demo/blob/main/misc/load.sh 
   3. Show the students the raw data and that the other datasets are empty
7. In Dataform, go to your development workspace and execute all the actions
   1. **Start execution > execute actions**
   2. Choose to execute with a service account **dataform-demo-sa@**
   3. Choose **Select actions to execute > Select all > OK**
   4. Click **Start execution**
8. Show the students the details of the execution
9.  Show the students the results in the BigQuery tables (dev tables)

## Discussion instructions

1. Ask the students where they might apply Dataform
2. Ask if they currently use other products, like dbt, to do the same thing
3. Show them how you'd configure and schedule a release configuration
4. Discuss other ways that you'd like trigger these actions
   1. **Cloud Composer** workflow with a [invocation operator](https://airflow.apache.org/docs/apache-airflow-providers-google/stable/operators/cloud/dataform.html#create-workflow-invocation) that invokes after BQ load is finished
   2. **Google Cloud Workflows**, calling the REST API for invocation after the BQ load is finished
   3. A **CI/CD pipeline** that calls the REST API or uses a client library after the BQ load is finished
   4. A **Cloud Function** that invokes via the API (using a client library) after it is triggered by a log event showing BQ load is done
   5. Examples are coming (feel free to write and submit a pull request)
5. Optional - show how the code can be edited in Dataform and pushed to Github

## Teardown

1. Use the pre-tf-cleanup.py to do some cleanup that Terraform can't
   1. create a virtual environment
   2. install the requirements
   3. run the script
      ```bash
      cd ~/dataform-demo/misc/
      python -m venv .venv
      source .venv/bin/activate
      pip install -r requirements.txt
      python pre-tf-cleanup.py
      ```
2. Then use Terraform to tear the rest down
   ```bash
   terraform destroy
   ```