resource "buildkite_pipeline" "performance_daily" {
  name        = "kibana / performance nightly"
  description = "Runs performance tests nightly"
  repository  = "https://github.com/suchcodemuchwow/kibana"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_CHANNEL: '#kibana-performance-alerts'
    SLACK_NOTIFICATIONS_ENABLED: 'true'
    SLACK_NOTIFICATIONS_ON_SUCCESS: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/performance/nightly.yml
  EOT

  default_branch       = "2021-11-25-synthetics-perf-test-login-and-home-page"
  branch_configuration = join(" ", local.current_dev_branches)
}

resource "buildkite_pipeline_schedule" "performance_daily_ci" {
  for_each = local.daily_branches

  pipeline_id = buildkite_pipeline.performance_daily.id
  label       = "Nightly build"
  cronline    = "0 9 * * * Europe/Berlin"
  branch      = each.value
}
