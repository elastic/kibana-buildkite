resource "buildkite_pipeline" "daily" {
  name        = "kibana / daily"
  description = "Runs full CI daily and on merge"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_CHANNEL: '#kibana-operations-alerts'
    SLACK_NOTIFICATIONS_ENABLED: 'true'
    REPORT_FAILED_TESTS_TO_GITHUB: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/hourly.yml
  EOT

  default_branch       = ""
  branch_configuration = join(" ", local.daily_branches)

  provider_settings {
    build_branches      = true
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "code"
  }
}

resource "buildkite_pipeline_schedule" "daily-ci" {
  for_each = local.daily_branches

  pipeline_id = buildkite_pipeline.daily.id
  label       = "Daily build"
  cronline    = "0 9 * * * America/New_York"
  branch      = each.value
}

resource "github_repository_webhook" "daily" {
  repository = "kibana"

  configuration {
    url          = buildkite_pipeline.daily.webhook_url
    content_type = "json"
    insecure_ssl = false
  }

  active = true

  events = ["push"]
}
