resource "buildkite_pipeline" "purge_cloud_deployments" {
  name        = "kibana / purge-cloud-deployments"
  description = "Purge stale cloud deployments"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    GITHUB_COMMIT_STATUS_ENABLED: 'true'
    SLACK_NOTIFICATIONS_ENABLED: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/purge_cloud_deployments.yml
  EOT

  default_branch       = "main"
  branch_configuration = "main"

  provider_settings {
    build_branches      = false
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "none"
  }
}

resource "buildkite_pipeline_schedule" "purge_cloud_deployments_daily" {
  for_each = toset(local.hourly_branches)

  pipeline_id = buildkite_pipeline.purge_cloud_deployments.id
  label       = "Daily purge"
  cronline    = "0 7 * * * America/New_York"
  branch      = each.value
}
