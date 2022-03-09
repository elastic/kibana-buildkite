resource "buildkite_pipeline" "purge_cloud_deployments" {
  name        = "kibana / purge-cloud-deployments"
  description = "Purge stale cloud deployments"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_ENABLED: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/purge_cloud_deployments.yml
      agents:
        queue: kibana-default
  EOT

  default_branch       = "main"
  branch_configuration = "main"

  provider_settings {
    build_branches      = false
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "none"
  }

  team {
    slug = "everyone"
    access_level = "MANAGE_BUILD_AND_READ"
  }
}

resource "buildkite_pipeline_schedule" "purge_cloud_deployments_hourly" {
  pipeline_id = buildkite_pipeline.purge_cloud_deployments.id
  label       = "Hourly purge"
  cronline    = "0 * * * * America/New_York"
  branch      = "main"
}
