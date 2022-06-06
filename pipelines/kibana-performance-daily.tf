resource "buildkite_pipeline" "single_user_performance" {
  name        = "kibana / single-user-performance"
  description = "Runs single user performance tests for kibana"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_CHANNEL: '#kibana-performance-alerts'
    SLACK_NOTIFICATIONS_ENABLED: 'true'
    BAZEL_CACHE_MODE: 'none'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/performance/daily.yml
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

resource "buildkite_pipeline_schedule" "single_user_performance_daily" {
  pipeline_id = buildkite_pipeline.single_user_performance.id
  label       = "Single user daily test"
  cronline    = "0 * * * * Europe/Berlin"
  branch      = buildkite_pipeline.single_user_performance.default_branch
}
