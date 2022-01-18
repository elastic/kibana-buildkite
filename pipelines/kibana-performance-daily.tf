resource "buildkite_pipeline" "performance_daily" {
  name        = "kibana / performance daily"
  description = "Runs performance tests daily"
  repository  = "https://github.com/elastic/kibana"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_CHANNEL: '#kibana-performance-alerts'
    SLACK_NOTIFICATIONS_ENABLED: 'true'
    SLACK_NOTIFICATIONS_ON_SUCCESS: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/performance/daily.yml
  EOT

  default_branch       = "main"
  branch_configuration = join(" ", local.current_dev_branches)
}

resource "buildkite_pipeline_schedule" "performance_daily_ci" {
  for_each = toset(local.current_dev_branches)

  pipeline_id = buildkite_pipeline.performance_daily.id
  label       = "Daily build"
  cronline    = "0 9 * * * Europe/Berlin"
  branch      = each.value
  env         = {
    PERF_TEST_COUNT="100"
  }
}
