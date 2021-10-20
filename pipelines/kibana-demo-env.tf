resource "buildkite_pipeline" "demo-env" {
  name        = "kibana / demo-environment"
  description = "Creates/updates demo environment for kibana with example plugins"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_CHANNEL: '#kibana-operations-alerts'
    SLACK_NOTIFICATIONS_ENABLED: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/update_demo_env.yml
  EOT

  default_branch       = "master"
  branch_configuration = join(" ", local.current_dev_branches)

  provider_settings {
    build_branches      = false
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "none"

    publish_commit_status = false
  }
}

resource "buildkite_pipeline_schedule" "demo-env-daily" {
  for_each = toset(local.current_dev_branches)

  pipeline_id = buildkite_pipeline.demo-env.id
  label       = "Daily build"
  cronline    = "0 7 * * * America/New_York"
  branch      = each.value
}
