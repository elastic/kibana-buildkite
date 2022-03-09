resource "buildkite_pipeline" "docker_context" {
  name        = "kibana / build docker context"
  description = "Build Docker context"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_ENABLED: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/docker_context.yml
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
}

resource "buildkite_pipeline_schedule" "docker_context_daily" {
  for_each = toset(local.hourly_branches)

  pipeline_id = buildkite_pipeline.docker_context.id
  label       = "Daily build"
  cronline    = "0 7 * * * America/New_York"
  branch      = each.value
}
