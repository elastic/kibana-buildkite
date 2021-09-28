Manage the buildkite pipelines with Terraform

### Setup

 1. Install Terraform: https://learn.hashicorp.com/tutorials/terraform/install-cli
 2. Create a Buildkite API token at https://buildkite.com/user/api-access-tokens
    - use `write_pipelines` and `read_pipelines` REST API scopes, and enable GraphQL.
 3. Create a Github API token
    - use `repo` permission and **Enable SSO** for Elastic
 4. Setup your Terraform variables in a `terraform.tfvars` file:

      ```
      buildkite_token = "TOKEN"
      github_owner = "elastic"
      github_token = "TOKEN"
      ```

 5. Ensure you have the [gcloud CLI](https://cloud.google.com/sdk/docs/install) installed and authenticated with an account that can acess the `elastic-kibana-ci-kibana-pipelines-tfstate` GCS bucket in the `elastic-kibana-ci` project.
    - If you're on a GCP instance you might need to add your service account to the permission list for the bucket.
 5. Run `terraform init`

### Testing

 1. Run `terraform plan` to see the changes which will be made once you commit and push your changes

### Deploy

 1. A Buildkite job runs on each commit to the `pipelines` directory which applys the changes to the Terraform definitions.