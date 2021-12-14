resource "buildkite_pipeline" "macos-bazel-cache" {
  name        = "kibana / macos bazel cache"
  description = "Bootstraps and populates Bazel remote cache"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_CHANNEL: '#kibana-operations-alerts'
    SLACK_NOTIFICATIONS_ENABLED: 'true'
    GITHUB_BUILD_COMMIT_STATUS_ENABLED: 'true'
    GITHUB_COMMIT_STATUS_CONTEXT: 'macos-bazel-cache'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/bazel_cache.yml
      # These concurrency settings work with the same concurrency settings in the pipeline code in the kibana repo
      # They are temporary while we only have 1 macos agent available and keep the builds in a "waiting" state if another pipeline is currently executing
      # Keeping them in a waiting state will allow intermediate commits to be skipped whenever a new build starts
      concurrency_group: bazel_macos
      concurrency: 1
      concurrency_method: eager
  EOT

  default_branch       = "main"
  branch_configuration = "main"
  # branch_configuration = join(" ", local.hourly_branches)

  skip_intermediate_builds = true

  provider_settings {
    build_branches      = true
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "code"
  }
}

resource "github_repository_webhook" "macos-bazel-cache" {
  repository = "kibana"

  configuration {
    url          = buildkite_pipeline.macos-bazel-cache.webhook_url
    content_type = "json"
    insecure_ssl = false
  }

  active = true

  events = ["push"]
}
