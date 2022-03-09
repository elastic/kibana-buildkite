resource "buildkite_pipeline" "hourly" {
  name        = "kibana / hourly"
  description = "Runs full CI hourly"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_CHANNEL: '#kibana-operations-alerts'
    SLACK_NOTIFICATIONS_ENABLED: 'true'
    REPORT_FAILED_TESTS_TO_GITHUB: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/hourly.yml
      agents:
        queue: kibana-default
  EOT

  default_branch       = "main"
  branch_configuration = join(" ", local.hourly_branches)

  provider_settings {
    trigger_mode = "none"
  }

  team {
    slug = "everyone"
    access_level = "MANAGE_BUILD_AND_READ"
  }
}

resource "buildkite_pipeline_schedule" "hourly-ci" {
  for_each = toset(local.hourly_branches)

  pipeline_id = buildkite_pipeline.hourly.id
  label       = "Hourly build"
  cronline    = "0 * * * * America/New_York"
  branch      = each.value
}
