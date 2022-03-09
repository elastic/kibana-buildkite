resource "buildkite_pipeline" "remote_dev_packer" {
  name        = "kibana / remote-dev-packer"
  description = "Runs daily packer build for remote dev base image"
  repository  = "https://github.com/elastic/kibana-remote-dev.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_ENABLED: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/packer.yml
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

resource "buildkite_pipeline_schedule" "remote_dev_packer_daily" {
  pipeline_id = buildkite_pipeline.remote_dev_packer.id
  label       = "Daily build"
  cronline    = "0 7 * * * America/New_York"
  branch      = buildkite_pipeline.remote_dev_packer.default_branch
}
