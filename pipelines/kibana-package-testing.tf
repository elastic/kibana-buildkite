resource "buildkite_pipeline" "package_testing" {
  name        = "kibana / package-testing"
  description = "Daily testing of rpm, deb, docker installs"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    GITHUB_COMMIT_STATUS_ENABLED: 'true'
    SLACK_NOTIFICATIONS_ENABLED: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/package_testing.yml
      agents:
        queue: kibana-default
  EOT

  default_branch       = "main"
  branch_configuration = join(" ", local.hourly_branches)

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

resource "buildkite_pipeline_schedule" "package_testing_daily" {
  for_each = toset(local.hourly_branches)

  pipeline_id = buildkite_pipeline.package_testing.id
  label       = "Daily build"
  cronline    = "0 7 * * * America/New_York"
  branch      = each.value
}
