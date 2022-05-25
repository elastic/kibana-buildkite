resource "buildkite_pipeline" "agent_packer" {
  name        = "kibana / agent / packer / full"
  description = "Runs packer builds for Buildkite agent images, base and cache"
  repository  = "https://github.com/elastic/kibana-buildkite.git"
  steps       = <<-EOT
  env:
    GITHUB_COMMIT_STATUS_ENABLED: 'true'
    SLACK_NOTIFICATIONS_ENABLED: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload agents/.buildkite/pipeline.yml
      agents:
        queue: kibana-default
  EOT

  default_branch       = "main"
  branch_configuration = "main"

  provider_settings {
    build_branches      = false
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "code"
  }

  team {
    slug         = "everyone"
    access_level = "MANAGE_BUILD_AND_READ"
  }
}

resource "buildkite_pipeline_schedule" "agent_packer_daily" {
  pipeline_id = buildkite_pipeline.agent_packer.id
  label       = "Daily build"
  cronline    = "0 7 * * * America/New_York"
  branch      = buildkite_pipeline.agent_packer.default_branch
}

resource "buildkite_pipeline" "agent_packer_cache" {
  name        = "kibana / agent / packer / cache"
  description = "Runs packer build for Buildkite agent cache image"
  repository  = "https://github.com/elastic/kibana-buildkite.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_ENABLED: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload agents/.buildkite/cache.yml
      agents:
        queue: kibana-default
  EOT

  default_branch       = "main"
  branch_configuration = "main"

  provider_settings {
    build_branches      = false
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "code"
  }

  team {
    slug         = "everyone"
    access_level = "MANAGE_BUILD_AND_READ"
  }
}
