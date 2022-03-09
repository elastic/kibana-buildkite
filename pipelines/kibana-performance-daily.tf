resource "buildkite_pipeline" "single_user_performance" {
  name        = "kibana-single-user-performance"
  description = "Runs single user performance tests for kibana"
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
  branch_configuration = "main"
}

resource "buildkite_pipeline_schedule" "single_user_performance_daily" {
  pipeline_id = buildkite_pipeline.single_user_performance.id
  label       = "Single user daily test"
  cronline    = "0 * * * * Europe/Berlin"
  branch      = buildkite_pipeline.single_user_performance.default_branch
  env         = {
    TEST_BROWSER_HEADLESS=1
  }
}
