resource "buildkite_pipeline" "fleet_packages" {
  name        = "kibana / fleet-packages"
  description = "Installs all fleet packages into Kibana to ensure the install step works"
  repository  = "https://github.com/elastic/kibana"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_CHANNEL: '#fleet'
    SLACK_NOTIFICATIONS_ENABLED: 'false'
    SLACK_NOTIFICATIONS_ON_SUCCESS: 'false'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/fleet/packages_daily.yml
      agents:
        queue: kibana-default
  EOT

  default_branch       = "main"
  branch_configuration = "main"

  team {
    slug = "everyone"
    access_level = "MANAGE_BUILD_AND_READ"
  }
}

resource "buildkite_pipeline_schedule" "fleet_packages_daily" {
  pipeline_id = buildkite_pipeline.fleet_packages.id
  label       = "Single user daily test"
  cronline    = "0 9 * * * America/New_York"
  branch      = buildkite_pipeline.fleet_packages.default_branch
  env         = {
  }
}
